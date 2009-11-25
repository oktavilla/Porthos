# == Schema Information
# Schema version: 76
#
# Table name: textfields
#
#  id         :integer(11)   not null, primary key
#  shared     :boolean(1)    
#  filter     :string(255)   
#  class_name :string(255)   
#  body       :text          
#  created_at :datetime      
#  updated_at :datetime      
#  title      :string(255)   
#

class Textfield < ActiveRecord::Base
  has_many :contents, :as => :resource
  has_many :default_contents, :as => :resource
  validates_presence_of :body, :on => :update
  validates_presence_of :title, :on => :update, :if => Proc.new { |textfield| textfield.shared? }  
  before_destroy do |textfield|
    if textfield.shared? and textfield.contents.any?
      textfield.contents.destroy_all
    end
  end
  
  # FIXME: We need to check if we no longer is a shared content and if not create a new instance and save that instead
  # before_update do |textfield|
  # end
  
  named_scope :shared, :conditions => ["shared = ?", 1]
  
end
