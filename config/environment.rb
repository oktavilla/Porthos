
# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
gem 'desert', '=0.5.3'
require 'desert'

Rails::Initializer.run do |config|
  config.autoload_paths += %W( #{Rails.root}/vendor/plugins/porthos/app/middleware #{Rails.root}/vendor/plugins/porthos/app/metal )

  config.active_record.observers = :node_observer
  
  config.time_zone = 'UTC +01:00'
  
  config.gem 'mime-types',
              :lib => 'mime/types'
  config.gem 'chronic'
  config.gem 'RedCloth'
  config.gem 'hpricot'
  config.gem 'mini_magick',
              :version => '=1.2.5'
  config.gem 'chardet',
              :lib => 'UniversalDetector'
  config.gem 'money'
  config.gem 'will_paginate',
              :version => '~> 2.3.11',
              :source => 'http://gemcutter.org'
  config.gem 'sunspot_rails', 
              :lib => 'sunspot/rails',
              :version => '=1.1.0'
  config.gem 'delayed_job'
end