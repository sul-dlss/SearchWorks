# frozen_string_literal: true

require 'http'

class FolioClient
  DEFAULT_HEADERS = {
    accept: 'application/json, text/plain',
    content_type: 'application/json'
  }.freeze

  attr_reader :base_url

  def initialize(url: ENV.fetch('OKAPI_URL'),
                 username: ENV.fetch('OKAPI_USER', nil),
                 password: ENV.fetch('OKAPI_PASSWORD', nil),
                 tenant: 'sul')
    uri = URI.parse(url)

    @base_url = url
    @username = username
    @password = password

    if uri.user
      @username ||= uri.user
      @password ||= uri.password
      @base_url = uri.dup.tap do |u|
        u.user = nil
        u.password = nil
      end.to_s
    end

    @tenant = tenant
  end

  # FOLIO Edge API - Real Time Availability Check
  # https://s3.amazonaws.com/foliodocs/api/edge-rtac/p/edge-rtac.html
  def real_time_availability(instance_ids:, full_periodicals: true)
    body = {
      instanceIds: instance_ids,
      fullPeriodicals: full_periodicals
    }
    post_json('/rtac-batch', body: body.to_json)
  end

  private

  def post(path, **kwargs)
    authenticated_request(path, method: :post, **kwargs)
  end

  def post_json(path, **kwargs)
    parse(post(path, **kwargs))
  end

  # @param [HTTP::Response] response
  # @raises [StandardError] if the response was not a 200
  # @return [Hash] the parsed JSON data structure
  def parse(response)
    raise response unless response.status.ok?
    return nil if response.body.empty?

    JSON.parse(response.body)
  end

  def session_token
    @session_token ||= begin
      response = request('/authn/login', json: { username: @username, password: @password }, method: :post)
      raise response.body unless response.status.created?

      response['x-okapi-token']
    end
  end

  def authenticated_request(path, headers: {}, **other)
    request(path, headers: headers.merge('x-okapi-token': session_token), **other)
  end

  def request(path, headers: {}, method: :get, **other)
    HTTP
      .headers(default_headers.merge(headers))
      .request(method, base_url + path, **other)
  end

  def default_headers
    DEFAULT_HEADERS.merge({ 'X-Okapi-Tenant': @tenant, 'User-Agent': 'FolioApiClient' })
  end
end
