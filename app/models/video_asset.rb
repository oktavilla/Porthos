class VideoAsset < Asset
  has_one :thumbnail, :class_name => 'ImageAsset', :foreign_key => 'parent_id', :dependent => :destroy
  after_destroy :remove_symlink

  def attributes_for_js
    self.attributes.merge({ :thumbnail => self.thumbnail.attributes })
  end

protected
  # before validation on create
  def process
    if @file
      file_extname           = File.extname(@file.original_filename)
      self.file_name         = @file.original_filename.gsub(file_extname,'').parameterize
      self.file_name         = make_unique_filename(file_name) unless Asset.count(:conditions => {:file_name => self.file_name}).zero?
      self.extname           = file_extname.gsub(/\./,'').downcase
      self.size              = @file.size
      self.mime_type         = MIME::Types.type_for(@file.original_filename).first.to_s
      write_to_disk
      create_thumbnail
      self.width  = thumbnail.width
      self.height = thumbnail.height
      file_extname == '.flv' ? symlink_to_public : convert_to_flv 
      self.title             = file_name.gsub(/\-/,'_').humanize if title.blank?
    end
  end  
  
  def convert_to_flv
    Dir.mkdir(public_video_path) unless File.exists?(public_video_path)
    system "(/usr/local/bin/ffmpeg -v 0 -i #{path} -ar 22050 -ab 64 -b 1500kbps -y #{flv_path}; /usr/local/bin/flvtool2 -U #{flv_path});chmod 644 #{flv_path}&"
  end
  
  def thumbnail_position=(marker)
    create_thumbnail :position => marker
  end

  def create_thumbnail(options = {:position => 8})
    self.thumbnail.destroy if self.thumbnail
    thumbnail_name = "#{file_name}_thumbnail.jpg"
    if self.extname == 'flv'
      system("/usr/local/bin/flvtool2 -U #{path}")
    end
    system("/usr/local/bin/ffmpeg -i #{path} -vframes 1 -ss #{options[:position]} -f image2 -an /tmp/#{thumbnail_name}")
    if File.exists? "/tmp/#{thumbnail_name}"
      self.thumbnail = ImageAsset.create({:file => Asset.new_tempfile("/tmp/#{thumbnail_name}"), :private => true})
      File.unlink "/tmp/#{thumbnail_name}"
    end
  end

  def symlink_to_public
    Dir.mkdir(public_video_path) unless File.exists?(public_video_path)
    system("ln -nfs #{path} #{flv_path}")
  end

  def remove_symlink
    system("rm #{flv_path}")
  end

  def flv_path
    File.join(Rails.root, 'public', 'videos', "#{file_name}.flv")
  end
  
  def public_video_path
    File.join(Rails.root, 'public', 'videos')
  end
end