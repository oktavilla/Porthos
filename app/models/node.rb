# == Schema Information
# Schema version: 76
#
# Table name: nodes
#
#  id             :integer(11)   not null, primary key
#  parent_id      :integer(11)   
#  name           :string(255)   
#  slug           :string(255)   
#  status         :integer(11)   default(0)
#  position       :integer(11)   
#  controller     :string(255)   
#  action         :string(255)   
#  resource_type  :string(255)   
#  resource_id    :integer(11)   
#  created_at     :datetime      
#  updated_at     :datetime      
#  children_count :integer(11)   
#

class Node < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  
  accepts_nested_attributes_for :resource

  def resource_type=(r_type)
     super(r_type.to_s.classify.constantize.base_class.to_s)
  end
  
  # Hack to make nested attributes for polymorphic relations
  def resource=(in_resource)
    if in_resource.is_a?(HashWithIndifferentAccess)
      in_resource.each do |key, value|
        self.resource[key] = value
      end
    else
      resource = in_resource
    end
  end

  validates_presence_of :name, :controller, :action

  acts_as_tree :order => 'position', :counter_cache => :children_count
  acts_as_list :scope => 'parent_id', :column => 'position', :order => 'position'

  before_save :generate_slug
  after_save  :generate_slug_for_children
  after_destroy :destroy_children, :destroy_resource
  
  def redraw_route?
    @redraw_route ||= false
  end

  def access_status
    @access_status ||= case status
    when -1 : 'inactive'
    when  0 : 'hidden'
    when  1 : 'active'
    end
  end

  def active?
    access_status == 'active'
  end
  
  def hidden?
    access_status == 'hidden'
  end
  
  def inactive?
    access_status == 'inactive'
  end
  
  class << self
    def for_page(page)
      returning(self.new) do |node|
        node.name       = page.title
        node.controller = page.class.base_class.to_s.tableize
        node.action     = 'show'
        node.resource   = page
        node.resource_class_name = page.class.to_s
        node.parent = Node.root if node.parent_id.blank?
      end
    end
  end

private

  # before save
  def generate_slug
    old_slug  = slug
    if parent
      self.slug = !parent.parent_id.blank? ? "#{parent.slug}/#{name.to_url}" : name.to_url
    end
    @redraw_route = old_slug != slug
    slug
  end
  
  # after save
  def generate_slug_for_children
    children.each(&:save) if children.any?
  end

  # after destroy
  def destroy_children
    children.destroy_all if children.any?
  end

  # after destroy
  def destroy_resource
    resource.destroy if resource
  end

end
