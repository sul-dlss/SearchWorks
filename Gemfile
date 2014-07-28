source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.3'
gem 'i18n', '0.6.9' # 0.6.10 yanked

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
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
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'lyberteam-capistrano-devel'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
end

group :sqlite do
  gem 'sqlite3'
end

group :production do
  gem 'mysql'
end

group :test do
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'coveralls', require: false
end

gem "coderay"

gem 'openseadragon', github: 'sul-dlss/openseadragon-rails'

gem 'deprecation'

gem 'blacklight', '~> 5.5.2'

gem "jettywrapper", "~> 1.7"
gem "devise"
gem "devise-guests", "~> 0.3"
gem "blacklight-marc", "~> 5.0"
gem "faraday"
gem "rails_config"
gem "mods_display", "0.3.3"
gem "blacklight-gallery", github: 'projectblacklight/blacklight-gallery'
gem "blacklight_advanced_search"
gem "font-awesome-sass"
gem "blacklight_range_limit"
gem "retina_tag"
gem 'jquery-datatables-rails', '~> 2.1.10.0.3'
