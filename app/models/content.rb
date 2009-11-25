# == Schema Information
# Schema version: 76
#
# Table name: contents
#
#  id                              :integer(11)   not null, primary key
#  page_id                         :integer(11)   
#  column_position                 :integer(11)   
#  position                        :integer(11)   
#  resource_id                     :integer(11)   
#  resource_type                   :string(255)   
#  created_at                      :datetime      
#  updated_at                      :datetime      
#  parent_id                       :integer(11)   
#  type                            :string(255)   
#  accepting_content_resource_type :string(255)   
#

class Content < ActiveRecord::Base
  belongs_to :page
  belongs_to :content_collection, :foreign_key => 'parent_id'
  belongs_to :resource, :polymorphic => true
  named_scope :active, :conditions => "contents.active = 1"
  acts_as_list :scope => 'page_id = \'#{page_id}\' AND column_position = \'#{column_position}\' AND parent_id #{(parent_id.blank? ? "IS NULL" : (" = " + parent_id.to_s))}'
  
  acts_as_settingable
  
  # Should destroy resource unless it's shared in any sence
  before_destroy do |content|
    if content.resource and not content.module? and not content.form?
      content.resource.destroy unless content.resource.has_attribute?(:shared) and content.resource.shared?
    end
  end

  # Should destroy content_collection if last child
  after_destroy do |content|
    unless content.parent_id.blank?
      content.content_collection.destroy if Content.count(:conditions => ["parent_id = ?", content.parent_id]) == 0
    end
  end

  def validate
    errors.add(:resource_type, "är inte av rätt typ") if resource_type and not self.approved_resources.include?(resource_type)
  end

  def text?
    resource_type == 'Textfield'
  end
  
  def shared?
    resource and resource.has_attribute?(:shared) and resource.shared?
  end

  def module?
    resource_type == 'ContentModule'
  end

  def form?
    resource_type == 'RegistrationForm'
  end

  def resource_template
    "admin/contents/#{resource_type.underscore.pluralize}/#{resource_type.underscore}.html.erb"
  end

  def collection_template
    "admin/contents/#{resource_type.underscore.pluralize}/collection.html.erb"
  end

  def collection?
    self.is_a?(ContentCollection)
  end

  def approved_resources
    self.class.approved_resources
  end

  def self.approved_resources
    ['Textfield', 'Teaser', 'ContentModule', 'RegistrationForm', 'ContentImage', 'ContentMovie']
  end

end
