# frozen_string_literal: true

##
# For cleaning up nicely presented sms messages
class SmsPresenter
  include ActionView::Helpers

  attr_reader :document, :url

  SMS_LENGTH = 160

  def initialize(document, url)
    @document = document
    @url = url
  end

  def sms_content
    "#{sms_text}\n#{url}\n"
  end

  private

  def sms_text
    truncate(document.to_sms_text, length: text_length, escape: false)
  end

  def text_length
    SMS_LENGTH - url.length - 4
  end
end
