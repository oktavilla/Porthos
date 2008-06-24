class FlashAsset < MovieAsset

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
      get_dimensions
      write_to_disk
      self.size              = @file.size
      self.mime_type         = MIME::Types.type_for(@file.original_filename).first.to_s
      self.title             = file_name.gsub(/\-/,'_').humanize if title.blank?
      symlink_to_public
    end
  end  
  
  def get_dimensions
    dimensions = ImageSpec::Dimensions.new(@original_path_with_ext)
    self.width  = dimensions.width
    self.height = dimensions.height
  end

  def symlink_to_public
    movie_dir = File.join(RAILS_ROOT, 'public', 'swf')
    Dir.mkdir(movie_dir) unless File.exists?(movie_dir)
    system("ln -nfs #{path} #{symlink_path}")
  end

  def symlink_path
    File.join(RAILS_ROOT, 'public', 'swf', full_name)
  end
end