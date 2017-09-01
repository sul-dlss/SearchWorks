# frozen_string_literal: true

Bitly.use_api_version_3

Bitly.configure do |config|
  config.api_version = 3
  config.access_token = Settings.BITLY.ACCESS_TOKEN
end
