source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'

gem 'sprockets', '~> 3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
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
  gem 'rspec-rails', '~> 5.0'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'solr_wrapper'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

group :sqlite do
  gem 'sqlite3'
end

group :production do
  gem 'mysql2'
end

group :test do
  gem 'simplecov', '~> 0.14', require: false
end

gem 'newrelic_rpm'

gem "coderay"

gem 'deprecation'

gem 'blacklight', '~> 7.27'
gem "blacklight-marc", "~> 8.0"
gem "blacklight_advanced_search", '~> 8.0.0.alpha'
gem "blacklight_range_limit", "~> 8.0"
gem 'blacklight-hierarchy', "~> 6.0"
gem 'blacklight_dynamic_sitemap'
gem 'rsolr'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'nokogiri', '>= 1.7.1'
gem "devise"
gem "devise-guests"
gem 'devise-remote-user'
gem "faraday", "~> 0.10"
gem "config"
gem "mods_display", "~> 1.0"
gem "font-awesome-rails"
gem "retina_tag"
gem 'jquery-datatables-rails'
gem 'roadie-rails', '~> 2'
gem 'rack-utf8_sanitizer'
gem 'ebsco-eds'
gem 'sanitize', '~> 6.0' # "optional" dependency as of ebsco-eds 1.1.2
gem 'whenever' # manages cron jobs
gem 'bitly', '>= 2.0.0.beta' # For bit.ly
gem 'bootsnap', require: false
gem 'leaflet-rails'
gem 'recaptcha', '>= 5.4.1'
gem 'oauth2', '~> 1.4' # Pinning so we don't get downgraded
gem 'rinku', require: 'rails_rinku'
gem 'bootstrap-sass'
gem 'rack-attack' # For throttle configuration
gem 'global_alerts'
gem 'faraday-detailed_logger', '< 2.4.0' # Fixes https://github.com/sul-dlss/SearchWorks/issues/2759
