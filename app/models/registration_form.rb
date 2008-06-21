# == Schema Information
# Schema version: 76
#
# Table name: registration_forms
#
#  id                     :integer(11)   not null, primary key
#  contact_person_id      :integer(11)   
#  name                   :string(255)   
#  template               :string(255)   
#  send_email_response    :boolean(1)    
#  replyable_email        :boolean(1)    
#  reply_to_email         :string(255)   
#  email_subject          :string(255)   
#  email_body             :text          
#  created_at             :datetime      
#  updated_at             :datetime      
#  type                   :string(255)   
#  target_code            :string(255)   
#  default_amounts        :string(255)   
#  notification_person_id :integer(11)   
#  product_category_id    :integer(11)   
#

class RegistrationForm < ActiveRecord::Base
  belongs_to :contact_person, :class_name => 'User', :foreign_key => 'contact_person_id'
  belongs_to :notification_person, :class_name => 'User', :foreign_key => 'notification_person_id'
  has_one :page, :dependent => :nullify, :as => :parent

  def amounts
    default_amounts.split(',').collect { |amount| amount.to_i }
  end

  def available_templates
    @available_templates ||= self.class.find_available_templates
  end

  def parsed_email_body(*args)
    @template ||= Liquid::Template.parse(email_body)
    @template.render(*args)
  end
  
  def notification_message
    ActionController::Base.render :text => "hello world!"
  end

  class << self
    def find_available_templates
      [RAILS_ROOT + '/app/views/pages/contents/registration_forms', File.dirname(__FILE__) + '/../views/pages/contents/registration_forms'].collect do |path|
        Dir.entries(path).reject { |entry| File.directory?(entry) }.collect { |file| File.basename(file, '.html.erb').gsub(/^\_/, '') } if File.exists? path
      end.flatten.compact.uniq.sort
    end
  end

protected
  
  def validate
    template = parsed_email_body({})
  rescue
    errors.add(:email_body, "innehåller syntax fel")
  end

  
end
