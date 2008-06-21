require 'porthos/porthos'
require 'money'
require 'will_paginate'

Money.default_currency = "SEK"

simple_localization :language => :sv, :lang_file_dir => "#{RAILS_ROOT}/config/languages", :except => :localized_templates

ExceptionNotifier.exception_recipients = %w(errors@winstondesign.se)
ExceptionNotifier.sender_address = %("Application Error" <error@unicef.se>)
ExceptionNotifier.email_prefix = "[UNICEF] "

PORTHOS_ROOT = "#{RAILS_ROOT}/vendor/plugins/porthos"