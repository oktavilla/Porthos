class Node < ActiveRecord::Base
  belongs_to :resource,
             :polymorphic => true,
             :dependent => :destroy
  
  accepts_nested_attributes_for :resource

  def resource_type=(r_type)
     super(r_type.to_s.classify.constantize.base_class.to_s)
  end
  
  before_validation :generate_slug
  validates_uniqueness_of :slug
  validates_presence_of :name, :controller, :action

  acts_as_tree :order     => 'position',
               :dependent => :destroy

  acts_as_list :scope  => :parent,
               :column => 'position',
               :order  => 'position'

  before_update :add_to_list_bottom,
               :if => Proc.new { |node| node.parent_id_changed? }
  after_update :reposition_former_list,
               :if => Proc.new { |node| node.parent_id_changed? }

  after_save  :generate_slug_for_children

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
    if parent
      self.slug = !parent.parent_id.blank? ? [parent.slug, name.parameterize.to_s].join('/') : name.parameterize.to_s
    end
  end

  # before save when moved to another list, decrement all nodes in the former list
  # (ie. parent_id_changed?)
  def reposition_former_list
    acts_as_list_class.update_all("#{position_column} = (#{position_column} - 1)", "parent_id = #{parent_id_was} AND #{position_column} > #{position_was}")
  end

  # after save
  def generate_slug_for_children
    children.each(&:save) if slug_changed? && children.any?
  end
  
end
