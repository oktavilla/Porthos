# == Schema Information
# Schema version: 76
#
# Table name: teasers
#
#  id                  :integer(11)   not null, primary key
#  title               :string(255)   
#  body                :text          
#  link                :string(255)   
#  parent_type         :string(255)   
#  parent_id           :integer(11)   
#  image_asset_id      :integer(11)   
#  created_at          :datetime      
#  updated_at          :datetime      
#  product_category_id :integer(11)   
#  product_id          :integer(11)   
#  position            :integer(11)   
#  css_class           :string(255)   
#  display_type        :string(255)   
#  images_display_type :integer(11)   default(0)
#

class Teaser < ActiveRecord::Base
  has_one :content, :as => :resource
  
  belongs_to :parent, :polymorphic => true
  belongs_to :product_category
  belongs_to :product
  
  has_many :asset_usages, :as => :parent, :order => 'position', :dependent => :destroy
  has_many :images, :source => :asset, :through => :asset_usages, :order => 'position', :conditions => "assets.type = 'ImageAsset'", :select => "assets.*, asset_usages.gravity" do
    def primary
      find(:first)
    end
  end

  acts_as_list :scope => 'parent_id = \'#{parent_id}\' and parent_type = \'#{parent_type}\''

  validates_presence_of :title, :body
  
  attr_accessor :files
  
  DISPLAY_TYPES       = { :small => '0', :medium => '1', :big => '2' }
  IMAGE_DISPLAY_TYPES = { :only_first_image => 0, :slideshow => 1 }
  CSS_CLASSES = [
    ['Ingen', ''],
    ['Ljusmagenta', 'light_magenta'],
    ['Ljuscyan', 'light_cyan'],
    ['Ljusgrön', 'light_green'],
    ['Magenta', 'magenta'],
    ['Cyan', 'cyan'],
    ['Grön', 'green'],
    ['Röd', 'red']
  ]
  
  after_save :save_files
  
  def small?
    display_type == DISPLAY_TYPES[:small]
  end
  
  def medium?
    display_type == DISPLAY_TYPES[:medium]
  end
  
  def big?
    display_type == DISPLAY_TYPES[:big]
  end
  
  def has_slideshow?
    images.size > 1 and images_display_type == IMAGE_DISPLAY_TYPES[:slideshow]
  end
  
protected
  # after save
  def save_files
    if files
      files.each do |file|
        begin
          if file and file.size.nonzero?
            AssetUsage.transaction do
              image = ImageAsset.create!(:title => title, :file => file)
              asset_usage = self.asset_usages.build
              asset_usage.asset = image
              asset_usage.save!
            end
          end
        rescue ActiveRecord::RecordInvalid
          next
        end
      end
    end
  end
end
