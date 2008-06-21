class ImageResource < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :image, :class_name => 'ImageAsset', :foreign_key => 'image_asset_id'
  acts_as_list :scope => 'parent_id = #{parent_id} and parent_type = \'#{parent_type}\'', :column => 'position', :order => 'position'

  # Used when uploading new images to a product
  attr_accessor :file
  
  validates_presence_of :parent_id, :parent_type
  validates_presence_of :image_asset_id, :if => Proc.new { |img| !(img.file and img.file.size.nonzero?) }
  before_save :store_asset

protected
  # before filter
  def store_asset
    self.image = ImageAsset.create(:file => file) if file and file.size.nonzero?
  end

end
