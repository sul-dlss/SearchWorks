# frozen_string_literal: true

require 'http'

class OclcDiscoveryClient
  MAX_CITATIONS_PER_REQUEST = 50
  DEFAULT_HEADERS = {
    accept: 'application/json',
    accept_language: 'en',
    user_agent: 'Stanford Libraries SearchWorks'
  }.freeze

  attr_reader :base_url, :token_url, :authorize_url

  def initialize(base_url: Settings.oclc_discovery.base_url,
                 client_key: Settings.oclc_discovery.client_key,
                 client_secret: Settings.oclc_discovery.client_secret,
                 token_url: Settings.oclc_discovery.token_url,
                 authorize_url: Settings.oclc_discovery.authorize_url)
    @base_url = base_url
    @client_key = client_key
    @client_secret = client_secret
    @token_url = token_url
    @authorize_url = authorize_url
  end

  # Overridden so that we don't display client key and secret
  def inspect
    "#<#{self.class.name}:#{object_id} " \
      "@base_url=\"#{base_url}\" @token_url=\"#{token_url}\" @authorize_url=\"#{authorize_url}\">"
  end

  def ping
    session_token.present?
  rescue HTTP::Error
    false
  end

  # Fetch one or more citations from the OCLC Discovery API
  # @param [Array] or [String] the OCLC numbers to fetch citations for
  # @param [Array] or [String] citation_styles one or more citation styles to fetch
  # @return [Array] one or more citation responses
  def citations(oclc_numbers:, citation_styles: ['apa'])
    Array(oclc_numbers).each_slice(MAX_CITATIONS_PER_REQUEST).map do |ids|
      Thread.new { get_json(citation_query(ids.join(','), Array(citation_styles).join(','))) }
    end.map(&:value)
  end

  private

  # OCLC Citation API documentation:
  # https://developer.api.oclc.org/citations-api
  def citation_query(oclc_number, citation_styles)
    query = { oclcNumbers: oclc_number, style: citation_styles }.to_query
    "/reference/citations?#{query}"
  end

  def get_json(path)
    parse(authenticated_request(path))
  end

  def parse(response)
    raise response unless response.status.ok?
    return nil if response.body.empty?

    JSON.parse(response.body)
  end

  def authenticated_request(path)
    get_request(path, headers: { authorization: "Bearer #{session_token}" })
  end

  def get_request(path, headers: {})
    HTTP.headers(DEFAULT_HEADERS.merge(headers)).request(:get, base_url + path)
  end

  def session_token
    @session_token ||= oauth_client.client_credentials.get_token.token
  end

  def oauth_client
    OAuth2::Client.new(@client_key, @client_secret, site: base_url, token_url:, authorize_url:)
  end
end
