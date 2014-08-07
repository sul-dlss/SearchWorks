require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ActionMailer::Base.default :from => 'no-reply@searchworks.stanford.edu'

module SearchWorks
  class Application < Rails::Application
    config.application_name = "SearchWorks"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    require 'constants'
    require 'page_location'
    require 'access_panels'
    require 'access_panel'
    require 'links'
    require 'nearby_on_shelf'
    require 'hours_request'
    require 'holdings'
    require 'live_lookup'
    require 'search_query_modifier'
    require 'custom_marc'

    # load all access panels
    config.autoload_paths += %W(#{config.root}/lib/access_panels)

    # load all marc_data_fields
    config.autoload_paths += %W(#{config.root}/lib/custom_marc)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
