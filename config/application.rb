require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ActionMailer::Base.default from: 'no-reply@searchworks.stanford.edu'

module SearchWorks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.application_name = "SearchWorks"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # load all marc fields
    config.autoload_paths << "#{root}/app/models/marc_fields"
    config.autoload_lib(ignore: %w(assets tasks))

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.middleware.insert 0, Rack::UTF8Sanitizer

    config.search_logger = ActiveSupport::Logger.new(Rails.root + 'log/search.log', 'daily')
  end
end
