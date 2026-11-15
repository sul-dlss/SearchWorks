# frozen_string_literal: true

# Renders the hidden reCAPTCHA v3 token field for a form. The Google script is not
# included here; the recaptcha Stimulus controller loads it from `script_url` the
# first time someone interacts with the form, so pages that merely contain a form
# (e.g. the feedback modal on every page) don't load reCAPTCHA.
class RecaptchaComponent < ViewComponent::Base
  attr_reader :action, :site_key

  def initialize(action:, site_key: Recaptcha.configuration.site_key)
    @action = action
    @site_key = site_key
    super()
  end

  # nil in environments where recaptcha is skipped (e.g. test), so nothing is loaded.
  def script_url
    return if Recaptcha.skip_env?(nil)

    "#{Recaptcha.configuration.api_server_url}?#{{ render: site_key }.to_query}"
  end
end
