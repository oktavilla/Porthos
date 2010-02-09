require 'porthos/porthos'
require 'money'
require 'will_paginate'

Money.default_currency = "SEK"

simple_localization :language => :sv, :lang_file_dir => "#{RAILS_ROOT}/config/languages", :except => :localized_templates

PORTHOS_ROOT = "#{RAILS_ROOT}/vendor/plugins/porthos"

ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store, FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])