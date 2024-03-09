# frozen_string_literal: true

require 'http'

class FolioClient # rubocop:disable Metrics/ClassLength
  DEFAULT_HEADERS = {
    accept: 'application/json',
    content_type: 'application/json'
  }.freeze

  attr_reader :base_url

  def initialize(url: Settings.folio.url,
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

  def ping
    session_token.present?
  rescue HTTP::Error
    false
  end

  # FOLIO mod-rtac Real Time Availability Check
  # https://s3.amazonaws.com/foliodocs/api/mod-rtac/p/rtac-batch.html
  def real_time_availability(instance_ids:, full_periodicals: true)
    body = {
      instanceIds: instance_ids,
      fullPeriodicals: full_periodicals
    }
    post_json('/rtac-batch', body: body.to_json)
  end

  def circulation_rules
    get_json('/circulation-rules-storage').fetch('rulesAsText', '')
  end

  # https://s3.amazonaws.com/foliodocs/api/mod-courses/r/courses.html#coursereserves_courses_get
  def courses
    get_json('/coursereserves/courses', params: { limit: 2_147_483_647 }).fetch('courses', []).sort_by { |x| x['id'] }.map do |course|
      instructors = course.dig('courseListingObject', 'instructorObjects').map { |x| x.slice('name') }
      course.slice('id', 'courseNumber', 'sectionName', 'name', 'description', 'termObject', 'metadata').merge('courseListingObject' => { 'instructorObjects' => instructors })
    end
  end

  def request_policies
    get_json('/request-policy-storage/request-policies', params: { limit: 2_147_483_647 }).fetch('requestPolicies', []).sort_by { |x| x['id'] }
  end

  def loan_policies
    get_json('/loan-policy-storage/loan-policies', params: { limit: 2_147_483_647 }).fetch('loanPolicies', []).sort_by { |x| x['id'] }
  end

  def lost_item_fees_policies
    get_json('/lost-item-fees-policies', params: { limit: 2_147_483_647 }).fetch('lostItemFeePolicies', []).sort_by { |x| x['id'] }
  end

  def overdue_fines_policies
    get_json('/overdue-fines-policies', params: { limit: 2_147_483_647 }).fetch('overdueFinePolicies', []).sort_by { |x| x['id'] }
  end

  def patron_notice_policies
    get_json('/patron-notice-policy-storage/patron-notice-policies', params: { limit: 2_147_483_647 }).fetch('patronNoticePolicies', []).sort_by { |x| x['id'] }
  end

  def patron_groups
    get_json('/groups', params: { limit: 2_147_483_647 }).fetch('usergroups', []).sort_by { |x| x['id'] }
  end

  def material_types
    get_json('/material-types', params: { limit: 2_147_483_647 }).fetch('mtypes', []).sort_by { |x| x['id'] }
  end

  def loan_types
    get_json('/loan-types', params: { limit: 2_147_483_647 }).fetch('loantypes', []).sort_by { |x| x['id'] }
  end

  def libraries
    get_json('/location-units/libraries', params: { limit: 2_147_483_647 }).fetch('loclibs', []).sort_by { |x| x['id'] }
  end

  def locations
    get_json('/locations', params: { limit: 2_147_483_647 }).fetch('locations', []).sort_by { |x| x['id'] }
  end

  def campuses
    get_json('/location-units/campuses', params: { limit: 2_147_483_647 }).fetch('loccamps', []).sort_by { |x| x['id'] }
  end

  def institutions
    get_json('/location-units/institutions', params: { limit: 2_147_483_647 }).fetch('locinsts', []).sort_by { |x| x['id'] }
  end

  def service_points
    get_json('/service-points', params: { limit: 2_147_483_647 }).fetch('servicepoints', []).sort_by { |x| x['id'] }
  end

  private

  def post(path, **kwargs)
    authenticated_request(path, method: :post, **kwargs)
  end

  def post_json(path, **kwargs)
    parse(post(path, **kwargs))
  end

  def get(path, **kwargs)
    authenticated_request(path, method: :get, **kwargs)
  end

  def get_json(path, **kwargs)
    parse(get(path, **kwargs))
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
