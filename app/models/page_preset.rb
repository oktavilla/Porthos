class PagePreset < ActiveRecord::Base
  belongs_to :graphic
  belongs_to :page_layout
  belongs_to :page_collection
  
  attr_accessor :graphic_file
  
  before_save :save_graphic
  
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
  
protected
  def save_graphic
    unless graphic_file.blank?
      self.graphic_id = Graphic.create(:file => graphic_file).id
    end  
  end
end
