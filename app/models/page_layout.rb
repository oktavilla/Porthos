# == Schema Information
# Schema version: 76
#
# Table name: page_layouts
#
#  id         :integer(11)   not null, primary key
#  css_id     :string(255)   
#  name       :string(255)   
#  columns    :integer(11)   default(1)
#  created_at :datetime      
#  updated_at :datetime      
#

class PageLayout < ActiveRecord::Base
  validates_presence_of :name, :css_id
  has_many :pages
  
  has_many :default_contents do
    def in_column(column, options = {})
      with_scope(:find => { :conditions => ["column_position = ?", column]}) do
        find(:all, options)
      end
    end
  end
  attr_accessor :contents
  
  after_save :store_default_contents
  after_save :remove_old_default_contents
  after_save :update_linked_pages

  class << self
    def can_be_edited_by?(user)
      user.has_role?('SiteAdmin')
    end

    def can_be_created_by?(user)
      user.has_role?('SiteAdmin')
    end

    def can_be_destroyed_by?(user)
      user.has_role?('SiteAdmin')
    end
  end

private
  def remove_old_default_contents
    DefaultContent.destroy_all("column_position > #{columns} and page_layout_id = #{id}")
  end
  
  def update_linked_pages
    Page.update_all("layout_class = '#{css_id}', column_count = #{columns}, main_content_column = '#{main_content_column}'", "page_layout_id = #{id}")
  end
  
  def store_default_contents
    default_contents.destroy_all if default_contents.any?
    contents.each do |column, types|
      types.each do |type, ids|
        if Content.approved_resources.include?(type)
          ids.each { |id| self.default_contents << DefaultContent.new(:column_position => column, :resource_type => type, :resource_id => id) }
        end
      end
    end unless contents.blank?
  end
end