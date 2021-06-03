source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.0'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
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
  gem 'rspec-rails', '~> 3.0'
  gem 'rails-controller-testing'
  gem 'webdrivers'
  gem 'launchy' # useful for debugging rspec/capybara integration tests -- put "save_and_open_page" in your test to debug
  gem 'solr_wrapper'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
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

gem 'blacklight', '~> 6.0'
gem 'rsolr'
gem 'nokogiri', '>= 1.7.1'
gem "devise"
gem "devise-guests"
gem 'devise-remote-user'
gem "blacklight-marc", "~> 6.0"
gem "faraday", "~> 0.10"
gem "config"
gem "mods_display", "~> 0.5"
gem "blacklight-gallery", '~> 0.4'
gem "blacklight_advanced_search", "~> 6.3"
gem "font-awesome-rails"
gem "blacklight_range_limit", "~> 6.2"
gem 'blacklight-hierarchy', "~> 4.0"
gem 'blacklight_dynamic_sitemap'
gem "retina_tag"
gem 'jquery-datatables-rails'
gem 'roadie-rails', '~> 2'
gem 'rack-utf8_sanitizer'
gem 'ebsco-eds', '1.1.1' # External vendor, upgrade requires testing
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
