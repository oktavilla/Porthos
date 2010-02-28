class Teaser < ActiveRecord::Base
  include Porthos::ContentResource

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

  @@filters = %w(wymeditor html textile)
  @@default_filter = 'wymeditor'
  cattr_accessor :filters
  cattr_accessor :default_filter
  
  def filter
    @filter ||= read_attribute(:filter) || default_filter
  end
  
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
