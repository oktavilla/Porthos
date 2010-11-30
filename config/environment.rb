# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
gem 'desert', '=0.5.3'
require 'desert'

Rails::Initializer.run do |config|
  config.load_paths += %W( #{Rails.root}/vendor/plugins/porthos/app/middleware #{Rails.root}/vendor/plugins/porthos/app/metal )

  config.active_record.observers = :node_observer
  
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