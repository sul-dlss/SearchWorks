# frozen_string_literal: true

# HTTP client wrapper for making requests to Symws
class SymphonyClient
  DEFAULT_HEADERS = {
    accept: 'application/json',
    content_type: 'application/json'
  }.freeze

  THREAD_COUNT = 10

  # get a session token by authenticating to symws
  def session_token
    @session_token ||= begin
      response = request('/user/staff/login', json: Settings.symws.login_params, method: :post)

      JSON.parse(response.body)['sessionToken']
    rescue JSON::ParserError
      Honeybadger.notify('Unable to connect to Symphony Web Services.')
      nil
    end
  end

  def bib_status(keys)
    responses = []
    mutex = Mutex.new
    
    THREAD_COUNT.times.map do
      Thread.new(keys, responses) do |keys, responses|
        while key = mutex.synchronize { keys.pop }
          response = authenticated_request(
            "/catalog/bib/key/#{ERB::Util.url_encode(key)}",
            params: {
              includeFields:
                'callList{itemList{circRecord{dueDate,recallDueDate},barcode,library,currentLocation,homeLocation}}'
            }, headers: {}
          )
          mutex.synchronize { responses << response }
        end
      end
    end.each(&:join)

    responses.map { |response| JSON.parse(response.body) }
  end

  private

  def authenticated_request(path, headers: {}, **other)
    request(path, headers: headers.merge('x-sirs-sessionToken': session_token), **other)
  end

  # rubocop:disable Metrics/AbcSize
  def request(path, headers: {}, method: :get, **other)
    Honeybadger.add_breadcrumb('Symphony request', metadata: {
                                 path: path,
                                 params: other[:params].to_json,
                                 json: other[:json].to_json
                               })

    response = HTTP
               .timeout(60)
               .use(instrumentation: { instrumenter: ActiveSupport::Notifications.instrumenter, namespace: 'symphony' })
               .headers(default_headers.merge(headers))
               .request(method, base_url + path, **other)

    Honeybadger.add_breadcrumb('Symphony response', metadata: { body: response.body.to_s })

    begin
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      Honeybadger.notify(e)
    end

    # let the specific API methods figure out what fallback to apply
    response
  rescue HTTP::Error => e
    Honeybadger.notify(e)

    # let the specific API methods figure out what fallback to apply
    raise e
  end
  # rubocop:enable Metrics/AbcSize

  def base_url
    Settings.symws.url
  end

  def default_headers
    DEFAULT_HEADERS.merge(Settings.symws.headers || {})
  end
end
