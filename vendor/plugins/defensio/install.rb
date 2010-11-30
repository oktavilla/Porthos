require 'fileutils'
FileUtils.cp "#{File.dirname(__FILE__)}/example/defensio.yml", "#{Rails.root}/config/defensio.yml"
puts File.read("#{File.dirname(__FILE__)}/README")