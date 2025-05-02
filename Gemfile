source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0'
gem "propshaft"
# Use Puma as the app server
gem 'puma', '~> 6.0'

gem 'turbo-rails', '~> 2.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.0'
  gem "letter_opener"
end

gem 'ruby-oembed'

gem 'okcomputer' # monitors application and its dependencies

gem 'honeybadger'

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'dlss-capistrano'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'capybara', '~> 3.0'
  gem 'launchy' # useful for debugging rspec/capybara integration tests -- put "save_and_open_page" in your test to debug
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 7.1'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-capybara', require: false
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '~> 4.0'
  gem 'webmock'
  # factory_bot_rails for creating fixtures in tests
  gem 'factory_bot_rails'
end

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '>= 2.0'

group :production do
  gem 'mysql2'
end

group :test do
  gem 'simplecov', '~> 0.14', require: false
end

gem 'newrelic_rpm'

gem "coderay"

gem 'blacklight', '~> 8.0'
gem "blacklight-marc", "~> 8.0"
gem "blacklight_advanced_search", '~> 8.0.0.alpha'
gem "blacklight_range_limit", "~> 8.0"
gem 'blacklight-hierarchy', "~> 6.0"
gem 'blacklight_dynamic_sitemap'
gem 'rsolr'
gem 'nokogiri', '>= 1.7.1'
gem "devise"
gem "devise-guests"
gem 'devise-remote-user'
gem "faraday"
gem 'faraday-follow_redirects'
gem 'oauth2'
gem "config"
gem "mods_display", "~> 1.1"
gem 'roadie-rails', '~> 3'
gem 'rack-utf8_sanitizer'
gem 'ebsco-eds'
gem 'sanitize', '~> 6.0' # "optional" dependency as of ebsco-eds 1.1.2
gem 'whenever', require: false # Work around https://github.com/javan/whenever/issues/831
gem 'recaptcha', '~> 5.17'
gem 'rinku', require: 'rails_rinku'
gem 'bootstrap', '~> 4.0'

gem 'rack-attack' # For throttle configuration
gem 'redis'

gem 'global_alerts'
gem 'view_component'

# Use for parsing FOLIO circulation rules
gem "parslet", "~> 2.0"

gem "jsbundling-rails", "~> 1.2"
gem "stimulus-rails", "~> 1.3"
gem "cssbundling-rails", "~> 1.4"

gem 'blacklight-ris', '~> 0.2.0'
