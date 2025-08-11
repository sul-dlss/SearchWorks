# frozen_string_literal: true

class RecaptchaComponent < ViewComponent::Base
  attr_reader :action, :inline_script, :site_key

  def initialize(action:, inline_script: false, site_key: Recaptcha.configuration.site_key)
    @action = action
    @inline_script = inline_script
    @site_key = site_key
    super()
  end
end
