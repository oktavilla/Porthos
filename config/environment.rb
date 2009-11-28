# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :active_resource, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  config.action_controller.session = {
    :session_key => '_porthos_session',
    :secret      => '8004777cabac95cfb27fea20d671d4db',
    :digest      => 'MD5'
  }

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :registration_observer, :node_observer, :payment_observer 

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # See Rails::Configuration for more options

  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory is automatically loaded
end
# hacks for swfupload + cookie store to work
# see http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload
#
# also need to put
# session :cookie_only => false, :only => :create
# into the controller where the files are being uploaded (change method as appropriate)
#
# this goes in environment.rb
class CGI::Session
  alias original_initialize initialize

  # The following code is a work-around for the Flash 8 bug that prevents our multiple file uploader
  # from sending the _session_id.  Here, we hack the Session#initialize method and force the session_id 
  # to load from the query string via the request uri. (Tested on  Lighttpd, Mongrel, Apache), Rails 2.1
  def initialize(cgiwrapper, option = {})
    # RAILS_DEFAULT_LOGGER.debug "#{__FILE__}:#{__LINE__} Session options #{option.inspect} *********************"
    unless option['cookie_only']
      # RAILS_DEFAULT_LOGGER.debug "#{__FILE__}:#{__LINE__} Initializing session object #{cgiwrapper.env_table['RAW_POST_DATA']} *********************"
      session_key = option['session_key'] || '_session_id'

      query_string = if (rpd = cgiwrapper.env_table['RAW_POST_DATA']) and rpd != ''
        rpd
      elsif (qs = cgiwrapper.env_table['QUERY_STRING']) and qs != ''
        qs
      elsif (ru = cgiwrapper.env_table['REQUEST_URI'][0..-1]).include?('?')
        ru[(ru.index('?') + 1)..-1]
      end
      if query_string and query_string.include?(session_key)
        option['session_data'] = CGI.unescape(query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first)
      end
    end
    original_initialize(cgiwrapper,option)
  end
end

class CGI::Session::ActiveRecordStore
  # Find or instantiate a session given a CGI::Session.
  def initialize(session, options = {})
    session_id = options['session_data'] || session.session_id # hack to allow session key fetching thru the query string
    unless @session = ActiveRecord::Base.silence { @@session_class.find_by_session_id(session_id) }
      unless session.new_session
        raise CGI::Session::NoSession, 'uninitialized session'
      end
      @session = @@session_class.new(:session_id => session_id, :data => {})
      # session saving can be lazy again, because of improved component implementation
      # therefore next line gets commented out:
      # @session.save
    end
  end
end

class CGI::Session::CookieStore
  alias original_initialize initialize
  def initialize(session, options = {})
    @session_data = options['session_data']
    original_initialize(session, options)
  end

  def read_cookie
    @session_data || @session.cgi.cookies[@cookie_options['name']].first
  end
end
