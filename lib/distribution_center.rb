require 'open-uri'
require 'hpricot'
require 'net/http'
require 'requires_parameters'
require 'cgi'
require 'iconv'
require 'UniversalDetector'
module DistributionCenter
  
  def self.string_to_cents(amount)
    amount.to_s.gsub(',', '.').to_i
  end
  
  module Base
    mattr_accessor :host
    self.host = 'http://unicef.webshop.strd.se/unicef/index.php'
  
    mattr_accessor :mode
    self.mode = :production
  end
  
  
  module Shipping
    
    class Response
      
      attr_reader :params
      attr_reader :message

      def initialize(success, params, options = {})
        @success, @params = success, params.stringify_keys
        @test = options[:test] || false
      end
      
      def success?
        @success
      end
      
      def test?
        @test
      end

    end

    class Shipment

      cattr_accessor :delivery_params
      
      self.delivery_params = {
       "organization"           => 'Company',
       "address"                => 'Addr1',
       "post_code"              => 'ZIP',
       "locality"               => 'City',
       "email"                  => 'Email',
       "phone"                  => 'Phone',
       "shipping_organization"  => 'Ship_Company',
       "shipping_name"          => 'Ship_Contact',
       "shipping_address"       => 'Ship_Addr1',
       "shipping_post_code"     => 'Ship_ZIP',
       "shipping_locality"      => 'Ship_City',
       "channel"                => 'FKanal',
       "customer_number"        => 'CLogin',
       "payment_transaction_id" => "TransactionID",
       "payment_type"           => "PaymentMethod",
       "order_type"             => "Shop"
      }

      attr_accessor :items
      
      def initialize(order, items)
        @order, @items = order, items
      end

      def deliver(options = {})
        shipping_params = map_shipping_params @order, options
        commit shipping_params
      end

      def map_shipping_params(shipping_params, options = {})
        params = {}
        params['Contact'] = "#{shipping_params["first_name"]} #{shipping_params["last_name"]}"

        self.class.delivery_params.each do |order_field, distribution_field|
          params[distribution_field] = shipping_params[order_field] if shipping_params[order_field]
        end

        if params['Addr1'].blank? or params['ZIP'].blank? or params['City'].blank?
          params['Addr1'], params['ZIP'], params['City'] = params['Ship_Addr1'], params['Ship_ZIP'], params['Ship_City']
        end
        
        params['Ship_Contact'] = "#{shipping_params["shipping_first_name"]} #{shipping_params["shipping_last_name"]}" if params['Ship_Contact'].blank? and !shipping_params['shipping_first_name'].blank? and !shipping_params['shipping_last_name'].blank?
        
        params.merge!(@items.to_delivery_h)

        params.each {|key, param| params[key] = param.to_latin1 if param }
        
        params['Test'] = '1' if (Base.mode == :test or Base.mode == :send_test)
        params
      end
      

      def test?
        self.class.test?
      end

      def self.test?
        Base.mode == :test
      end

      private

        def commit(post_data)
          response_body = nil
          distribution_post_vars = post_data.to_yaml
          unless test?
            url = URI.parse(Base.host)
            request = Net::HTTP::Post.new(url.path)
            request.set_form_data(post_data.merge({:fuseaction => 'basket.transfer_basket'}))
            http_response = Net::HTTP.new(url.host, url.port).start do |http| 
              http.request(request)
            end

            if http_response.code.to_i == 200 and http_response.body.include?('STRD_ORDER_NO')
              response = http_response.body.split("\n")[1]
              status, order_id, customer_number = response.split(';')
              if not Base.mode == :send_test
                success = status == "1"
              else
                success = status == "0"
              end
              response_body = http_response.body
            elsif http_response.code.to_i == 200
              response_body = http_response.body
              success, order_id, status, customer_number = false, nil, "Unknown error", ""
            else
              success, order_id, status, customer_number = false, nil, "Unable to contact distribution center", ""
            end
          else
            success, order_id, status, customer_number  = true, 999999, 1, "bogus"
          end

          Response.new(success, { :dispatch_id => order_id, :dispatch_status => status, :dispatch_customer_number => customer_number, :dispatch_full_response => response_body, :distribution_post_vars => distribution_post_vars }, { :test => test? })
        end


      class Items < Array

        cattr_accessor :wods
        self.wods = {
          'ALET' => 'A brev',
          'BLET' => 'B brev',
          'FP12' => 'Företagspaket 12:00',
          'FP16' => 'Företagspaket 16:00',
          'PPAK' => 'Postpaket'
        }

        def to_s
          reject { |i| i.free_postage == true }.collect do |item|
            [
              item.article_number,
              item.quantity,
              item.price.awesome_format.gsub(/\./,',')
            ].join(';')
          end.join('|')
        end
        
        def to_delivery_h
          delivery_h = {}
          each_with_index do |item, index|
            num = sprintf("%03.0f", index+1)
            delivery_h["ItemId#{ num }"]        = item.article_number.upcase
            delivery_h["isPostageFree#{ num }"] = item.free_postage ? '1' : '0'
            delivery_h["Qty#{ num }"]           = "#{item.quantity}"
            delivery_h["UPrice#{ num }"]        = "#{item.price.awesome_format}".gsub(/\./, ',')
          end
          delivery_h
        end

        def vat
          @vat ||= Money.new((delivery_costs[:vat].gsub(',', '.').to_f * 100).to_i)
        end

        def wod
          @wod ||= delivery_costs[:wod]
        end

        def net
          @net ||= Money.new((delivery_costs[:sum].gsub(',', '.').to_f * 100).to_i)
        end

        def gross
          @gross ||= Money.new((delivery_costs[:total].gsub(',', '.').to_f * 100).to_i)
        end

        class << self

          def from_cart(cart_items)
            returning(self.new) do |items|
              cart_items.each do |cart_item|
                items << returning(Item.new) do |item|
                  item.name           = cart_item.name
                  item.article_number = cart_item.article_number
                  item.quantity       = cart_item.quantity
                  item.price          = cart_item.price
                  item.free_postage   = cart_item.free_postage?
                end
              end
            end
          end
        end

      protected

        def delivery_costs
          return {:wod => "BLET", :vat => "25", :sum => "80", :total => "100"} if Base.mode == :test
          if @basket and @basket == self.to_s
            @delivery_costs
          else
            @delivery_costs = { :statuses => {} }
            @basket = self.to_s
            response = Net::HTTP.get_response(URI.parse("#{Base.host}?fuseaction=basket.getwodprice&minibasket=#{CGI.escape(@basket)}"))
            raise "Unable to access distribution center" unless response.code.to_i == 200

            lines = response.body.split("\n")
            
            detail_keys, detail_values, detail_products, detail_statuses = lines.collect { |line| line.split(';') }
            detail_keys.each_with_index do |item, index|
              @delivery_costs[item.chomp.to_sym] = detail_values[index].chomp
            end
            detail_products.each_with_index do |product, index|
              @delivery_costs[:statuses][product.chomp] = detail_statuses[index].chomp
            end
            @delivery_costs
          end
        end

        
      end
    end    
  end
  
  class PrintShipment < Shipment
    def wod
      false
    end
    
    def net
      @net ||= Money.new(6500*0.8)
    end
    
    def gross
      @gross ||= Money.new(6500)
    end
  end
  
  class Warehouse

    # include RequiredParameters

    def initialize(options = {})
      self.mode = :test if options[:test] == true
    end
  
    def items(*args)
      @items ||= find_items(*args)
    end
    
    def find_items(*args)
      Item.find(*args)
    end

    def test?
      self.class.test?
    end
    
    def self.test?
      Base.mode == :test
    end
    
  end
  
  class Item
    attr_accessor :articlenm, :articleno, :qty2del, :eta, :free_postage
    
    # Alias methods to cope with strd's naming
    alias_method :article_number, :articleno
    alias_method :article_number=, :articleno=
    alias_method :quantity, :qty2del
    alias_method :quantity=, :qty2del=
    alias_method :name, :articlenm
    alias_method :name=, :articlenm=
        
    def vat=(sum)
      @vat = sum
    end

    def vat
      @vat ||= 25
      (@vat.to_f / 100.00)
    end
    
    def price=(amount)
      @price = amount.is_a?(Money) ? amount : Money.new(amount)
    end
    
    def price
      @price
    end
    
    cattr_accessor :strd_fields
    self.strd_fields = %w[ArticleNo ArticleNm Qty2Del Vat Eta]
    
    def initialize(params = {})
      params.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=".to_sym)
      end
    end
    
    def test?
      self.class.test?
    end
    
    class << self
      
      def find(*args)
        if args.empty? or args.first == :all
          find_every
        elsif args.first.is_a?(String)
          find_one(args.first)
        else
          []
        end
      end
      
      def find_every
        doc = Hpricot.XML(open("#{Base.host}?fuseaction=basket.whsaldo&Format=4"))
        parse_items(doc)
      end
      
      def find_one(id)
        doc = Hpricot.XML(open("#{Base.host}?fuseaction=basket.whsaldo&Item_Id=#{id}&Format=4"))
        parse_items(doc).first
      end
      
      def test?
        Base.mode == :test
      end

    end
  protected
    def self.parse_items(doc)
      (doc/:Product).collect do |xml_item|
        attributes = {}
        strd_fields.each do |field_name|
          field_name = field_name.to_sym
          field      = (xml_item/field_name)
          unless field.nil?
            attributes[field_name.to_s.downcase.to_sym] = field.text.to_utf8
          end
        end
        # convert strds price format (ex 11,8) to cents
        if strd_price = (xml_item/"Price")
          attributes[:price] = (strd_price.text.gsub(',', '.').to_f * 100).to_i
        end
        Item.new(attributes)
      end
    end
  end
  
end