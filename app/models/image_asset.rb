class ImageAsset < Asset
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Asset'

  IMAGE_VERSIONS_DIR = "#{RAILS_ROOT}/public/images"
  RESIZE_SALT = '8i03d9ee7'
  
  def landscape?
    width > height
  end
  
  def portrait?
    not landscape?
  end
  
  def resize(options = {})
    return false unless magick_image
    options = {
      :quality         => 100,
      :remove_profiles => false
    }.merge!(options)

    options[:crop] ||= (options[:size] and options[:size].include?("c"))
    
    size = options[:size].gsub(/[^0-9a-z\-]/,'')

    Dir.mkdir images_dir unless File.exists? IMAGE_VERSIONS_DIR
    Dir.mkdir version_dir(size) unless File.exists? version_dir(size)
    
    magick_image.strip if options[:remove_profiles]
    
    format = if format_string = size.match(/^([0-9]*)x([0-9]*)$/)
      box_width = ($1.to_i > self.width) ? self.width : $1.to_i
      box_height = ($2.to_i > self.height) ? self.height : $2.to_i
      { :width => box_width, :height => box_height, :method => "resize" }
    elsif format_string = size.match(/^([a-z])([0-9]*)(x|)([0-9]*)(g\-|)([a-z]{1,2}|)$/)
      case format_string[1]
      when "c" then { :width => $2.to_i,                   :height => $4.to_i,                   :method => "crop",  :gravity => gravity_from_size($6) }
      when "w" then { :width => $2.to_i,                   :height => height_for_width($2.to_i), :method => "resize" }
      when "h" then { :width => width_for_height($2.to_i), :height => $2.to_i,                   :method => "resize" }
      end
    else
      if landscape?
        { :width => size.to_i, :height => height_for_width(size.to_i), :method => "resize" }
      else
        { :height => size.to_i, :width => width_for_height(size.to_i), :method => "resize" }
      end
    end

    magick_image.format('jpg') unless browser_compatible_format?

    format[:width]  = self.width  if format[:width].to_i >= self.width
    format[:height] = self.height if format[:height].to_i >= self.height
    unless format[:width] > self.width || format[:height] > self.height
      magick_image.combine_options do |i|
        case format[:method]
        when "crop"
          if height_for_width(format[:width]) > format[:height]
            i.resize( [ format[:width], height_for_width(format[:width]) ].join("x"))
          else
            i.resize( [ width_for_height(format[:height]), format[:height] ].join("x"))
          end
          i.crop([ format[:width], format[:height] ].join("x") + "+0+0")
          i.gravity format[:gravity]
        when "resize"
          i.resize([ format[:width], format[:height] ].join("x"))
        end
        i.quality options[:quality]
      end
      magick_image.write version_path(size)
    else
      if browser_compatible_format?
        FileUtils.copy(self.path, version_path(size))
      else
        magick_image.write version_path(size)
      end
    end
    FileUtils.chmod_R(0755, version_dir(size))
    magick_image.destroy
    @magick_image = nil
  end

  def height_for_width(new_width)
    unless new_width >= self.width
      (height.to_f * (new_width.to_f / self.width.to_f)).ceil
    else
      height
    end
  end

  def width_for_height(new_height)
    unless new_height >= self.height
      (width.to_f * (new_height.to_f / self.height.to_f)).ceil
    else
      width
    end
  end
  
  def version_dir(size)
    File.join(IMAGE_VERSIONS_DIR, size)
  end
  
  def version_path(size)
    File.join(version_dir(size), version_full_name)
  end
  
  def version_full_name
    @version_full_name ||= browser_compatible_format? ? full_name : "#{file_name}.jpg"
  end

  def self.thumbnail_flag
    "-thumbnail"
  end
  
  def thumbnail_flag
    self.class.thumbnail_flag
  end

  def resize_token(size)
    Digest::SHA1.hexdigest([RESIZE_SALT, self.full_name, size].join('-'))[1..6]
  end
  
protected

  def gravity_from_size(key)
    gravities.keys.include?(key.to_s) ? gravities[key] : gravities['c']
  end

  def gravities
    {
      'nw' => 'NorthWest',
      'n'  => 'North',
      'ne' => 'NorthEast',
      'w'  => 'West',
      'c'  => 'Center',
      'e'  => 'East',
      'sw' => 'SouthWest',
      's'  => 'South',
      'se' => 'SouthEast'
    }
  end
  
  def magick_image(file_path = nil)
    @magick_image ||= MiniMagick::Image.from_file(file_path || path)
    rescue Errno::ENOENT
      return false 
  end
  
  def browser_compatible_format?
    %w(jpg jpeg png gif).include?(read_attribute(:extname))
  end

  def validate_on_create  
    image = magick_image(path)
    return errors.add(:file, t(:unknown_format, :scope => [:app, :image_asset])) unless image
  end

  # before create
  def process
    super
    self.width, self.height = magick_image[:width], magick_image[:height]
    # Garbage collect the generated minimagic tempfile
    magick_image.destroy
    @magick_image = nil
  end
    
  # after destroy
  def cleanup
    super
    Dir["#{RAILS_ROOT}/public/images/*/*"].each do |file| 
      File.unlink(file) if File.basename(file) == full_name
    end
  end
  
end
