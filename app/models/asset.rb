require 'digest/sha1'
require 'mime/types'
class Asset < ActiveRecord::Base
  belongs_to :created_by, :class_name => 'User'
  has_many   :usages, :class_name => 'AssetUsage', :dependent => :destroy
  
  has_one :child, :class_name => 'Asset', :foreign_key => 'parent_id', :dependent => :destroy
  
  named_scope :is_public,
              :conditions => { :private => false }
  named_scope :filter_created_by, lambda { |user_id| {
    :conditions => ["created_by_id = ?", user_id]
  }}
  named_scope :filter_by_type, lambda { |type| {
    :conditions => ["type = ?", type]
  }}
  named_scope :filter_order_by, lambda { |order| {
    :order => order
  }}

  is_indexed({
    :fields => ['type', 'title', 'file_name', 'author', 'description'],
    :concatenate => [{
      :class_name => 'Tag',
      :field      => 'name',
      :as         => 'tags', 
      :association_sql => "LEFT OUTER JOIN taggings ON (assets.id = taggings.taggable_id AND taggings.taggable_type = 'Asset') LEFT OUTER JOIN tags ON (tags.id = taggings.tag_id)"
    }],
    :conditions => 'private = 0',
    :delta => true
  })
  
  acts_as_taggable
  acts_as_filterable
  
  SAVE_DIR = "#{RAILS_ROOT}/assets"
  IMAGE_FORMATS = [:jpg, :jpeg, :png, :gif]
  MOVIE_FORMATS = [:flv, :mov, :qt, :mpg, :avi, :mp4]
  SOUND_FORMATS = [:mp3, :wav, :aiff, :aif]
  FLASH_FORMATS = [:swf]

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

  def image?
    IMAGE_FORMATS.include?(extname.to_sym) rescue false
  end
  
  def thumbnail?
    image? and file_name.include?("thumbnail") rescue false
  end

  def movie?
    MOVIE_FORMATS.include?(extname.to_sym) rescue false
  end
  
  def sound?
    SOUND_FORMATS.include?(extname.to_sym) rescue false
  end
  
  def flash?
    FLASH_FORMATS.include?(extname.to_sym) rescue false
  end

  def require_thumbnail?
    require_thumbnail == true
  end
  
  def attributes_for_js
    self.attributes
  end

  def creator_name
    @creator ||= created_by ? created_by.name : nil
  end

  class << self
    def from_upload(attrs)
      extname = File.extname(attrs[:file].original_filename.downcase).gsub(/\./,'')
      if IMAGE_FORMATS.include?(extname.to_sym)
        klass = ImageAsset 
      elsif MOVIE_FORMATS.include?(extname.to_sym)
        klass = MovieAsset 
      elsif SOUND_FORMATS.include?(extname.to_sym)
        klass = SoundAsset
      elsif FLASH_FORMATS.include?(extname.to_sym)
        klass = FlashAsset
      else
        klass = Asset
      end
      klass.new(attrs)
    end
    
    def new_tempfile(content_path)
      tempfile = ActionController::UploadedTempfile.new('temp')       
      tempfile.write IO.readlines(content_path) if File.exists?(content_path)
      tempfile.original_path = content_path
      tempfile.flush
      tempfile
    end
    
    def new_tempfile_from_url(url)
      data = open(url)
      if data.size > 0
        temp_path = "/tmp/"+File.basename(data.base_uri.path)
        File.open(temp_path, 'wb') { |disk_file| disk_file.write(data.read) }
        Asset.new_tempfile(temp_path)
      end
    end
  end

  def to_param
    file_name
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
      self.file_name         = make_unique_filename(self.file_name) unless Asset.count(:conditions => {:file_name => self.file_name}).zero?
      write_to_disk
    end
  end

  def write_to_disk
    Dir.mkdir(SAVE_DIR) unless File.exists?(SAVE_DIR)
    if @file.is_a? Tempfile
      FileUtils.move(@file.local_path, path)
    else
      File.open(path, 'wb') { |disk_file| disk_file.write(@file.read) }
    end
    File.chmod 0644, path # -rw-r--r--
    logger.info "Stored asset: #{path}"
  end

  # after destroy
  def cleanup
    File.unlink(path) if File.exists?(path)
   end
  
  def make_unique_filename(string)
    chars = ("a".."z").to_a + ("1".."9").to_a 
    self.file_name = string + '_' + Digest::SHA1.hexdigest(string + Array.new(8, '').collect{chars[rand(chars.size)]}.join + Time.now.to_s)[14..20]
  end
end