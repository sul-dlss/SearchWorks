source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.11'
gem 'nokogiri', '1.6.5' # nokogiri/nom-xml throwing error in 1.6.6
gem 'sprockets', '~> 2.11.3'
gem 'i18n'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.5'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

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
  gem 'lyberteam-capistrano-devel'
end

group :development, :test do
  gem 'rspec-rails', '< 2.99'
  gem 'capybara'
  gem 'poltergeist'
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

gem 'openseadragon', github: 'sul-dlss/openseadragon-rails', branch: 'ff36-fix'

gem 'deprecation'

gem 'blacklight', '~> 5.8.2'

gem "jettywrapper", "~> 1.7"
gem "devise"
gem "devise-guests"
gem 'devise-remote-user'
gem "blacklight-marc", "~> 5.0"
gem "faraday"
gem "rails_config"
gem "mods_display", "0.3.3"
gem "blacklight-gallery", github: 'projectblacklight/blacklight-gallery'
gem "blacklight_advanced_search", github: 'projectblacklight/blacklight_advanced_search'
gem "font-awesome-sass"
gem "blacklight_range_limit", github: 'projectblacklight/blacklight_range_limit'
gem 'blacklight-hierarchy', "~> 0.1.0"
gem "retina_tag"
gem 'jquery-datatables-rails', '~> 2.2.1'
gem 'roadie-rails', '~> 1.0.3'
gem 'whenever', require: false
