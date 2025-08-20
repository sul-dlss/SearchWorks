# frozen_string_literal: true

Config.setup do |config|
  # Name of the constat exposing loaded settings
  config.const_name = 'Settings'

  config.use_env = true
  config.env_prefix = 'SETTINGS'
  config.env_separator = '__'
  config.env_converter = :downcase
  config.env_parse_values = true

  # Ability to remove elements of the array set in earlier loaded settings file. Default: nil
  # config.knockout_prefix = '--'
end
