source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

gem 'ruby-oembed'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'squash_ruby', require: 'squash/ruby'
gem 'squash_rails', require: 'squash/rails'

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
  gem 'capybara'
  # We use database cleaner to empty out the database between tests (see spec_helper for usage)
  gem 'database_cleaner'
  gem 'poltergeist', '>= 1.8.1'
  gem 'launchy' # useful for debugging rspec/capybara integration tests -- put "save_and_open_page" in your test to debug
end

group :sqlite do
  gem 'sqlite3'
end

group :production do
  gem 'mysql2'
end

group :test do
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'coveralls', require: false
end

gem 'newrelic_rpm'

gem "coderay"

gem 'openseadragon', github: 'sul-dlss/openseadragon-rails'

gem 'deprecation'

gem 'blacklight', '~> 5.8.2'
gem 'nokogiri', '~> 1.6.7'
gem "jettywrapper", "~> 1.7"
gem "devise"
gem "devise-guests"
gem 'devise-remote-user'
gem "blacklight-marc", "~> 5.0"
gem "faraday"
gem "config"
gem "mods_display", "~> 0.4.0"
gem "blacklight-gallery", github: 'projectblacklight/blacklight-gallery'
gem "blacklight_advanced_search", github: 'projectblacklight/blacklight_advanced_search'
gem "font-awesome-sass"
gem "blacklight_range_limit", github: 'projectblacklight/blacklight_range_limit'
gem 'blacklight-hierarchy', "~> 0.1.0"
gem "retina_tag"
gem 'jquery-datatables-rails', '~> 2.2.1'
gem 'roadie-rails', '~> 1.0.4'
gem 'whenever', require: false
gem 'rubocop', '~> 0.36'
