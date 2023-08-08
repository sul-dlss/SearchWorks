# Use a configured time for figuring out which global alerts are active.
GlobalAlerts::Alert.global_alert_time = Time.zone.parse(Settings.GLOBAL_ALERT_TIME) if Settings.GLOBAL_ALERT_TIME
