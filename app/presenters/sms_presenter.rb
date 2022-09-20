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
    "#{sms_text}\n#{short_url}\n"
  end

  private

  def sms_text
    truncate(document.to_sms_text, length: text_length, escape: false)
  end

  def text_length
    SMS_LENGTH - short_url.length - 4
  end

  ##
  # If the Bit.ly call fails, fallback to the URL
  # @return [String]
  def short_url
    @short_url ||= client.shorten(long_url: url).link
  rescue => e
    Rails.logger.warn("Could not shorten bit.ly url #{e.message}")
    url
  end

  def client
    @client ||= Bitly::API::Client.new(token: Settings.BITLY.ACCESS_TOKEN)
  end
end
