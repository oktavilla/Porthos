class MovieAsset < Asset
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
      self.file_name         = @file.original_filename.gsub(file_extname,'').to_url
      self.file_name         = make_unique_filename(file_name) unless Asset.count(:conditions => {:file_name => self.file_name}).zero?
      self.extname           = file_extname.gsub(/\./,'').downcase
      @original_path_with_ext = "#{@file.local_path}.#{self.extname}"
      FileUtils.move(@file.local_path, @original_path_with_ext)
      create_thumbnail
      self.width  = thumbnail.width
      self.height = thumbnail.height
      file_extname == '.flv' ? write_to_disk : convert_to_flv 
      self.size              = @file.size
      self.mime_type         = MIME::Types.type_for(@file.original_filename).first.to_s
      self.title             = file_name.gsub(/\-/,'_').humanize if title.blank?
      symlink_to_public
    end
  end  
  
  def convert_to_flv
    self.extname = 'flv'
    @file = new_tempfile "/tmp/#{self.file_name}.flv"
    system "(ffmpeg -v 0 -i #{@original_path_with_ext} -ar 22050 -ab 64 -b 1500kbps -y #{path}; rm #{@original_path_with_ext}; flvtool2 -U #{path})&"
  end

  def create_thumbnail
    unless thumbnail
      thumbnail_name = "{file_name}_thumbnail.jpg"
      system("ffmpeg -i #{@original_path_with_ext} -vframes 1 -ss 8 -f image2 -an /tmp/#{thumbnail_name}")
      if File.exists? "/tmp/#{thumbnail_name}"
        self.thumbnail = ImageAsset.create({:file => new_tempfile("/tmp/#{thumbnail_name}"), :private => true})
        File.unlink "/tmp/#{thumbnail_name}"
      end
    end
  end

  def symlink_to_public
    movie_dir = File.join(RAILS_ROOT, 'public', 'movies')
    Dir.mkdir(movie_dir) unless File.exists?(movie_dir)
    system("ln -nfs #{path} #{symlink_path}")
  end

  def remove_symlink
    system("rm #{symlink_path}")
  end

  def symlink_path
    File.join(RAILS_ROOT, 'public', 'movies', full_name)
  end
  
  def write_to_disk
    Dir.mkdir(SAVE_DIR) unless File.exists?(SAVE_DIR)
    FileUtils.copy(@original_path_with_ext, path)
  end
end