require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ActionMailer::Base.default from: 'no-reply@searchworks.stanford.edu'

module SearchWorks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.application_name = "SearchWorks"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # TODO: A temporary Rails 5.2+ fix until we determine master_key policies
    def credentials
      Rails.application.secrets
    end

    require 'constants'
    require 'page_location'
    require 'hours_request'
    require 'holdings'
    require 'purl_embed'
    require 'search_query_modifier'

    # load all marc fields
    config.autoload_paths += %W(#{config.root}/app/models/marc_fields)

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
