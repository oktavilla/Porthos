# 
# require 'rubygems'
# require 'credit_check'
# check = BusinessCheck::CreditCheck.new()
# person = BusinessCheck::Person.new({:first_name => 'Dsaea', :last_name => 'Ascvea', :person_number => '840516'})
# if check.authorize(person) == true
#   puts 'OK'
# else
#   puts 'Failure'
# end
#

require 'open-uri'
require 'hpricot'
require 'net/http'
require 'net/https'
require 'cgi'

module BusinessCheck

  module Base
    mattr_accessor :find_service
    self.find_service = 'https://www.businesscheck.se/service/search.asmx/'

    mattr_accessor :validate_service
    self.validate_service = 'https://www.businesscheck.se/service/credittemplate.asmx/'

    mattr_accessor :language
    self.language = 'sv'
  
    mattr_accessor :mode
    self.mode = :production
  end


  class CreditCheck
    include RequiresParameters
    
    LIGHT_QUERY = 1
    FULL_QUERY  = 2
    
    attr_accessor :authentication_query    
    
    def initialize(options = {})
      requires!(options, :customer_login, :user_login, :password)
      @number_of_attempts = 0
      
      @options = options.stringify_keys
      
      @authentication_query = {
        'CustomerLoginName' => @options['customer_login'],
        'UserLoginName'     => @options['user_login'],
        'Password'          => @options['password'],
        'Language'          => Base.language
      }
    end
    
    def authorize(person)
      return Response.new(true, 'test') if test?
      response = find(person)
      if response.class.base_class == Entity
        check_credit_validity(response)
      else
        response
      end
    rescue CreditCheckError => e
      SystemNotifier.deliver_alert(e, self)
      Response.new(false, 'Server error')
    end

    def test?
      self.class.test?
    end

    def self.test?
      Base.mode == :test
    end
    
  protected

    def find(entity, query_type = LIGHT_QUERY)
      response = send_query entity.find_service, build_query_string(entity, query_type)
      doc      = Hpricot.XML(response)
      hits     = (doc/:HitCount).first.inner_text.to_i
      success  = hits == 1
      if success
        entity.class.from_xml(doc)
      else
        case
        when hits > 1
          if @number_of_attempts < 2
            find(person, FULL_QUERY)
          else
            Response.new(success, 'To many results')
          end
        when hits == 0
          Response.new(success, 'Not found')
        when hits < 0
          Response.new(success, 'Invalid search')
        end
      end
    end
    
    def check_credit_validity(entity)
      query = build_query_string(entity, FULL_QUERY).merge('TemplateName' => 'unicef')
      response = send_query(entity.validate_service, query)
      doc      = Hpricot.XML(response)
      result   = (doc/:ValidationResult).first.inner_text.to_i
      success  = result == 0
      if success
        Response.new(success, 'Approved')
      else
        Response.new(success, (result != -1 ? 'Declined' : 'Error'))
      end
    end

  private
    
    def build_query_string
      raise "Not implemented in subclass"
    end
    
    def send_query(uri, post_data)
      url  = URI.parse(uri)
      # connect through ssl tunnel
      http = Net::HTTP.new("127.0.0.1", 4000)
      http_response = http.start do |https|
        request = Net::HTTP::Post.new(url.path)
        request.set_form_data(post_data)
        https.request(request)
      end
      http = nil
      if http_response.code.to_i == 200
        @number_of_attempts += 1
        http_response.body
      else
        raise CreditCheckError
      end
    end
  end
  
  class PersonCheck < CreditCheck

  private

    def build_query_string(person, query_type = LIGHT_QUERY, phonetic_search = false)
      query = {
        'PersonNumber' => person.person_number,
        'FirstName'    => person.first_name,
        'LastName'     => person.last_name,
        'Address'      => person.address,
        'City'         => person.city,
        'ZipCode'      => person.zip_code
      }
      query.merge!({
        'Address' => '',
        'City'    => '',
        'ZipCode' => ''
      }) if query_type == LIGHT_QUERY
      query.merge!( { 'PhoneticSearch' => (phonetic_search == false ? 'false' : 'true' ) } )
      @authentication_query.merge(query)
      
    end
  end
  
  class CompanyCheck < CreditCheck
  
  private
    
    def build_query_string(company, query_type = LIGHT_QUERY, phonetic_search = false)
      query = {
        'OrganizationNumber' => company.organization_number,
        'CompanyName'        => company.name
      }
      query.merge!( { 'PhoneticSearch' => (phonetic_search == false ? 'false' : 'true' ) } )
      @authentication_query.merge(query)
    end
  end
  
  class Entity
    def initialize(options = {})
      options.symbolize_keys.each { |attribute, value| self.send("#{attribute}=", value) if self.respond_to?(attribute) } 
    end
    
    def self.from_xml
      raise "Not implemented"
    end

    def validate_service
      Base.validate_service + "#{check_template}"
    end

    def find_service
      Base.find_service + "#{find_template}"
    end
    
  end
  
  class Person < Entity
    attr_accessor :person_number, :first_name, :last_name
    attr_accessor :address, :zip_code, :city  
    
    def find_template
      "SearchPerson2Ds"
    end
    
    def check_template
      "CreditTemplatePerson"
    end
    
    def self.from_xml(doc)
      Person.new({
        :first_name    => doc.search("FirstName").first.inner_text,
        :last_name     => doc.search("LastName").first.inner_text,
        :city          => doc.search("City").first.inner_text,
        :person_number => doc.search("PersonNumber").first.inner_text
      })
    end
    
  end
  
  class Company < Entity
    attr_accessor :organization_number, :name

    def find_template
      "SearchCompanyDs"
    end
    
    def credit_template
      "CreditTemplateCompany"
    end
    
    def self.from_xml(doc)
      Company.new({
        :organization_number  => doc.search("OrganizationNumber").first.inner_text,
        :name                 => doc.search("CompanyName").first.inner_text
      })
    end
  end
  
  class CreditCheckError < StandardError
  end
  
  class Response

    attr_reader :message

    def initialize(success, message = '')
      @success, @message = success, message
    end
    
    def success?
      @success == true
    end
  end
end