require 'digest/sha1'
require 'mime/types'

class PorthosGraphic < ActiveRecord::Base
  PUBLIC_PATH = "uploaded_graphics"
  SAVE_DIR    = File.join(RAILS_ROOT, 'public/images', PUBLIC_PATH)
  IMAGE_FORMATS = [:jpg, :png, :gif]
 
  validates_presence_of :file, :on => :create

  before_validation_on_create :process
  after_destroy :cleanup

  attr_accessor :file

  def path
    "#{SAVE_DIR}/#{full_name}"
  end

  def full_name
    file_name+'.'+extname
  end
  
  def landscape?
    width > height
  end
  
  def portrait?
    not landscape?
  end
  
  def public_name
    File.join(PUBLIC_PATH, full_name)
  end

protected

  # before validation on create
  def process
    if @file
      file_extname           = File.extname(@file.original_filename)
      self.size              = @file.size
      self.mime_type         = MIME::Types.type_for(@file.original_filename).first.to_s
      self.extname           = file_extname.gsub(/\./,'').downcase
      self.file_name         = @file.original_filename.gsub(file_extname,'').to_url
      self.title             = file_name.gsub(/\-/,'_').humanize if title.blank?
      self.file_name         = make_unique_filename(self.file_name) if File.exists?(path)
      image = magick_instance(path)
      self.width, self.height = image.columns, image.rows if image
      write_to_disk
    end
  end

  def write_to_disk
#    raise @file.is_a?(Tempfile).inspect
    Dir.mkdir(SAVE_DIR) unless File.exists?(SAVE_DIR)
    if @file.is_a? Tempfile
      FileUtils.copy(@file.local_path, path)
    else
      File.open(path, 'wb') { |disk_file| disk_file.write(@file.read) }
    end
    logger.info "Stored graphic: #{path}"
  end

  # after destroy
  def cleanup
    if File.exists? path and File.unlink path
      logger.info "Deleted graphic: #{path}"
    else
      logger.warn "Unable to delete graphic #{path}"
    end
  end

  def make_unique_filename(string)
    chars = ("a".."z").to_a + ("1".."9").to_a 
    self.file_name = string + '_' + Digest::SHA1.hexdigest(string + Array.new(8, '').collect{chars[rand(chars.size)]}.join + Time.now.to_s)[14..20]
  end
  
  def magick_instance(file = nil)
    @magick_image ||= Magick::Image.read(file || path).first rescue false
  end

end
