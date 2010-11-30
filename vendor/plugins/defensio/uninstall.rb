require 'fileutils'
config_file = "#{Rails.root}/config/defensio.yml"
FileUtils.rm config_file if File.exist? config_file