require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ActionMailer::Base.default from: 'no-reply@searchworks.stanford.edu'

module SearchWorks
  class Application < Rails::Application
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
    require 'access_panel'
    require 'access_panels'
    require 'access_panels/course_reserve'
    require 'access_panels/exhibit'
    require 'access_panels/library_location'
    require 'access_panels/online'
    require 'access_panels/sfx'
    require 'access_panels/temporary_access'
    require 'links'
    require 'hours_request'
    require 'holdings'
    require 'live_lookup'
    require 'purl_embed'
    require 'search_query_modifier'
    require 'blacklight_advanced_search/parsing_nesting_parser'
    require 'search_works_marc'

    # load all marc fields
    config.autoload_paths += %W(#{config.root}/app/models/marc_fields)

    # load all SearchWorksMarc
    config.autoload_paths += %W(#{config.root}/lib/search_works_marc)
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_controller.permit_all_parameters = true

    config.middleware.insert 0, Rack::UTF8Sanitizer

    # This will not be required once we upgrade to Blacklight 7
    config.action_dispatch.rescue_responses.merge!(
      "Blacklight::Exceptions::RecordNotFound" => :not_found
    )
  end
end
