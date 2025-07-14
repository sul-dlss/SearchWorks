# frozen_string_literal: true

# Use a configured time for figuring out which global alerts are active.
Rails.application.config.to_prepare do
  GlobalAlerts::Engine.config.application_name = 'SearchWorks'
  GlobalAlerts::Alert.global_alert_time = Time.zone.parse(Settings.global_alert_time) if Settings.global_alert_time
end
