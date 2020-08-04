require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SulBentoApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.after_initialize do
      # Set QuickSearch configs to values in our Settings files
      # (so we can handle them on an env by env basis in our standard way)
      QuickSearch::Engine::APP_CONFIG['searchers'] = Settings.ENABLED_SEARCHERS
      QuickSearch::Engine::APP_CONFIG['found_types'] = Settings.ENABLED_SEARCHERS
    end
  end
end
