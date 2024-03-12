# frozen_string_literal: true

##
# Pull full-text source data from the SFX XML endpoint and render it.
#
# Initializes with the a URI encoded SFX URL that would normally render
# the HTML form/links and append a parameter to it that returns XML instead.
#
# This class parses that XML and returns it both as ruby objects and an HTML rendering.
class SfxData
  FULL_TEXT_SERVICE_TYPE = 'getFullTxt'
  SFX_XML_RESPONSE_TYPE = 'sfx.response_type=multi_obj_xml'

  def initialize(base_sfx_url)
    @base_sfx_url = base_sfx_url
  end

  def targets
    return [] unless sfx_xml

    @targets ||= sfx_xml.xpath('//target').map do |t|
      next unless target_xml_is_fulltext?(t)

      Target.new(t)
    end.compact
  end

  class << self
    def url_without_sid(sfx_url)
      uri = Addressable::URI.parse(sfx_url)
      params = uri.query_values
      params.delete('sid') if params.present?
      uri.query_values = params

      uri.to_s
    end
  end

  private

  attr_reader :base_sfx_url

  def target_xml_is_fulltext?(target_xml)
    target_xml.xpath('./service_type').try(:text) == FULL_TEXT_SERVICE_TYPE &&
      target_xml.xpath('./is_related').try(:text) == 'no'
  end

  def sfx_xml
    return unless sfx_response.success?

    @sfx_xml ||= begin
      Nokogiri::XML.parse(sfx_response.body)
    rescue => e
      Honeybadger.notify("Unable to parse XML from #{sfx_url}. Failed with error: #{e}")
    end
  end

  def sfx_response
    @sfx_response ||= begin
      Faraday.new(url: sfx_url) do |faraday|
        faraday.use FaradayMiddleware::FollowRedirects
        faraday.adapter Faraday.default_adapter
      end.get
    rescue Faraday::ConnectionFailed
      Honeybadger.notify("SFX data for #{sfx_url} failed to load")

      NullResponse.new
    end
  end

  def sfx_url
    "#{base_sfx_url}&#{SFX_XML_RESPONSE_TYPE}"
  end

  ##
  # Object to model a single SFX target xml
  # and return an HTML representation of it
  class Target
    def initialize(target_xml)
      @target_xml = target_xml
    end

    def name
      target_xml.xpath('./target_public_name').try(:text)
    end

    def url
      target_xml.xpath('./target_url').try(:text)
    end

    def coverage
      target_xml.xpath('.//coverage_statement').map(&:text).select(&:present?)
    end

    def embargo
      target_xml.xpath('.//embargo_statement').map(&:text).select(&:present?)
    end

    def note
      target_xml.xpath('./note').map(&:text).select(&:present?)
    end

    private

    attr_reader :target_xml
  end

  ##
  # Null Response Object to be returned if the HTTP request fails
  class NullResponse
    def success?
      false
    end
  end
end
