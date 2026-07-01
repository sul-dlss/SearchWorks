# frozen_string_literal: true

# Configure Honeybadger to use a logger that respects HONEYBADGER_LOGGING_LEVEL.
# By default, the level setting is ignored when using the Rails logger.
# See: https://github.com/honeybadger-io/honeybadger-ruby/issues/375
if ENV['HONEYBADGER_LOGGING_LEVEL'].present?
  Honeybadger.configure do |config|
    logger = ActiveSupport::TaggedLogging.logger($stdout)
    logger.level = Logger.const_get(ENV['HONEYBADGER_LOGGING_LEVEL'].upcase)
    config.logger = logger
  end
end
