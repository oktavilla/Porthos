class AssetUsage < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :asset

  acts_as_list :scope => 'parent_id = #{parent_id} and parent_type = \'#{parent_type}\'', :column => 'position', :order => 'position'

  # Used when uploading new images to a product
  attr_accessor :file
  
  validates_presence_of :parent_id, :parent_type
  validates_presence_of :asset_id, :if => Proc.new { |a| !(a.file and a.file.size.nonzero?) }
  before_save :store_asset

protected
  # before filter
  def store_asset
    if file and file.size.nonzero?
      Asset.from_upload(from_upload).save
      self.asset = asset
    end
  end
end
