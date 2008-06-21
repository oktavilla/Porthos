# == Schema Information
# Schema version: 76
#
# Table name: assets
#
#  id          :integer(11)   not null, primary key
#  type        :string(255)   
#  title       :string(255)   
#  file_name   :string(255)   
#  mime_type   :string(255)   
#  extname     :string(255)   
#  width       :integer(11)   
#  height      :integer(11)   
#  size        :integer(11)   
#  created_at  :datetime      
#  updated_at  :datetime      
#  author      :text          
#  description :text          
#  created_by  :integer(11)   
#  incomplete  :integer(11)   default(0)
#

require 'RMagick'
class ImageAsset < Asset
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'MovieAsset'
  
  def landscape?
    width > height
  end
  
  def portrait?
    not landscape?
  end
  
  IMAGE_VERSIONS_DIR = "#{RAILS_ROOT}/public/images"
  
  def version_path(size)
    IMAGE_VERSIONS_DIR+'/'+size+'/'+full_name
  end
    
  def resize(options = {})
    return false unless image = magick_instance
    options = {
      :size => nil,
      :quality => 100,
      :scale => false,
      :remove_color_profiles => true
    }.merge!(options)
    options[:crop] ||= (options[:size] and options[:size].include?("c"))
    
    if options[:remove_color_profiles]
      # delete color profiles and comments to make the output image smaller
      image.color_profile = nil
      image.iptc_profile  = nil
    end

    _width, _height = options[:width], options[:height] unless options.include?(:size)
  
    size = if options.include?(:size)
      _width, _height =  case 
                         when options[:size].include?("x"): options[:size].split(/([0-9]*)x([0-9]*)/)[1..2]
                         when options[:size].include?("w"): [options[:size].split("w").last, nil]
                         when options[:size].include?("h"): [nil, options[:size].split("h").last]
                         else                               [options[:size], nil]
                         end
      options[:size]
    elsif _width and _height
      "#{width}x#{height}"
    elsif _width and not _height
      "w#{width}"
    elsif _height and not _width
      "h#{height}"
    end
  
    Dir.mkdir(IMAGE_VERSIONS_DIR) unless File.exists?(IMAGE_VERSIONS_DIR)
    save_path = "#{IMAGE_VERSIONS_DIR}/#{size}"
    Dir.mkdir(save_path) unless File.exists?(save_path)
    _width = self.width if _width.to_i >= self.width
    _height = self.height if _height.to_i >= self.height
    # Generate the resized image
    image = if options[:scale]
      image.scale(options[:scale].to_f)
    elsif not _width or not _height
      scale_factor = 1
      scale_factor = (_width.to_f  / image.columns.to_f) if _width
      scale_factor = (_height.to_f / image.rows.to_f)    if _height
      scale_factor = 1 if scale_factor > 1
      image.scale( scale_factor )
    else
      if options[:crop]
        image.crop_resized( _width.to_i, _height.to_i )
      else
        image.scale( _width.to_i, _height.to_i )
      end
    end
    image.write("#{save_path}/#{self.full_name}") { self.quality = options[:quality] }
    logger.info "Stored new version of #{self.full_name} with width: #{image.columns}, height: #{image.rows}, scale factor: #{scale_factor} and quality: #{options[:quality]}"
    FileUtils.chmod_R(0755, "#{save_path}/")
    image                                                                                                                                                                                                
  end

  def self.thumbnail_flag
    "-thumbnail"
  end
  
  def thumbnail_flag
    self.class.thumbnail_flag
  end

  def calculate_height_for_width(new_width)
    return height if new_width >= self.width
    factor = new_width.to_f / self.width.to_f
    (height * factor).ceil
  end

  def calculate_width_for_height(new_height)
    return width if new_height >= self.height
    factor = new_height.to_f / self.height.to_f
    (width * factor).ceil
  end

protected

  def validate_on_create  
    image = magick_instance(@file.path)
    return errors.add(:file, l(:image_asset, :unknown_format)) unless image
    errors.add(:file, l(:image_asset, :must_be_rgb)) unless image.colorspace == Magick::RGBColorspace
  end

  # before create
  def process
    super
    image = magick_instance(path)
    self.width, self.height = image.columns, image.rows if image
  end
    
  # after destroy
  def cleanup
    super
    # TODO: iterate over generated versions and remove them
  end

  def magick_instance(file = nil)
    @magick_image ||= Magick::Image.read(file || path).first rescue false
  end
  
end
