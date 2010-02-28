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
SESSION_KEY = '_porthos_session'

Rails::Initializer.run do |config|
  config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/porthos/app/middleware #{RAILS_ROOT}/vendor/plugins/porthos/app/metal )

  config.active_record.observers = :registration_observer, :node_observer
  
  config.gem 'RedCloth'
  config.gem 'mini_magick', :version => '=1.2.5'
end