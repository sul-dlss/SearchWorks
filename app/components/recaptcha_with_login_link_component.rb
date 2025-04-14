# frozen_string_literal: true

class RecaptchaWithLoginLinkComponent < ViewComponent::Base
  attr_reader :recaptcha_id, :classes, :noscript

  # You likely want to default to noscript for recaptcha. See https://github.com/sul-dlss/SearchWorks/issues/3873
  def initialize(recaptcha_id:, classes: 'col-sm-9 offset-sm-3', noscript: false)
    @recaptcha_id = recaptcha_id
    @classes = classes
    @noscript = noscript
    super
  end
end
