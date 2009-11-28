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
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Asset'
  
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
  
    resize_parameters = if format_string = options[:size].match(/([a-z])([0-9]*)(x|)([0-9]*)(g\-|)([a-z]{1,2}|)/)
      case format_string[1]
      when "c" then { :width  => $2.to_i, :height => $4.to_i, :method => "crop" }
      when "w" then { :width  => $2.to_i, :method => "resize" }
      when "h" then { :height => $2.to_i, :method => "resize" }
      end
    else
      { :width => options[:size].to_i, :height => calculate_height_for_width(options[:size].to_i), :method => "resize" }
    end
    resize_parameters[:gravity] = gravity_from_size($6)
  
  
    resize_parameters[:width]  = self.width  if resize_parameters[:width].to_i >= self.width
    resize_parameters[:height] = self.height if resize_parameters[:height].to_i >= self.height

    Dir.mkdir(IMAGE_VERSIONS_DIR) unless File.exists?(IMAGE_VERSIONS_DIR)
    save_path = "#{IMAGE_VERSIONS_DIR}/#{options[:size]}"
    Dir.mkdir(save_path) unless File.exists?(save_path)
    # Generate the resized image
    image = case resize_parameters[:method]
    when 'resize'
      if not resize_parameters[:width] or not resize_parameters[:height]
        scale_factor = 1
        scale_factor = (resize_parameters[:width].to_f  / image.columns.to_f) if resize_parameters[:width]
        scale_factor = (resize_parameters[:height].to_f / image.rows.to_f)    if resize_parameters[:height]
        scale_factor = 1 if scale_factor > 1
        image.scale(scale_factor)
      else
        image.scale(resize_parameters[:width], resize_parameters[:height])
      end
    when 'crop'
      image.crop_resized(resize_parameters[:width], resize_parameters[:height], resize_parameters[:gravity])
    end

    # Set rgb so we can atleast see the images in the browser even tho colors may (will) get scewed
    image.colorspace = Magick::RGBColorspace if image.colorspace != Magick::RGBColorspace
    image.write("#{save_path}/#{self.full_name}") do
      self.quality    = options[:quality]
    end
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

  def gravity_from_size(key)
    gravities.keys.include?(key.to_s) ? gravities[key] : gravities['c']
  end

  def gravities
    {
      'nw' => Magick::NorthWestGravity,
      'n'  => Magick::NorthGravity,
      'ne' => Magick::NorthEastGravity,
      'w'  => Magick::WestGravity,
      'c'  => Magick::CenterGravity,
      'e'  => Magick::EastGravity,
      'e'  => Magick::EastGravity,
      'e'  => Magick::EastGravity,
      'sw' => Magick::SouthWestGravity,
      's'  => Magick::SouthGravity,
      'sw' => Magick::SouthEastGravity
    }
  end

  def validate_on_create  
    image = magick_instance(@file.path)
    return errors.add(:file, l(:image_asset, :unknown_format)) unless image
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
    Dir["#{RAILS_ROOT}/public/images/*/*"].each do |file| 
      File.unlink(file) if File.basename(file) == full_name
    end
  end

  def magick_instance(file = nil)
    @magick_image ||= Magick::Image.read(file || path).first rescue false
  end
  
end
