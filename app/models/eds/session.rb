# frozen_string_literal: true

module Eds
  ##
  # A class to wrap the EBSCO::EDS::Session class.
  # We are wrapping this class so that we can easily instantiate a session object
  # without having to pass in all the session options every time (which is very versbose).
  class Session # rubocop:disable Metrics/ClassLength
    attr_reader :eds_params

    def initialize(session_token: nil, **kwargs)
      @eds_params = default_session_options.merge(kwargs)
      @session_token = session_token
    end

    def info(*)
      @info ||= get('/edsapi/rest/Info').body
    end

    def retrieve(dbid:, accession_number:, highlight: nil, ebook: 'ebook-pdf')
      response = post('/edsapi/rest/Retrieve', { DbId: dbid, An: accession_number, HighlightTerms: highlight, EbookPreferredFormat: ebook }).body
      record = response['Record'] if response.is_a?(Hash)

      exports = begin
        citation_exports(dbid:, accession_number:)
      rescue StandardError
        []
      end

      styles = begin
        citation_styles(dbid:, accession_number:)
      rescue StandardError
        []
      end

      {
        'SearchResult' => {
          'Data' => {
            'Records' => [record.merge('exports' => exports, 'styles' => styles)]
          }
        }
      }
    end

    def citation_exports(dbid:, accession_number:, format: 'all')
      get('/edsapi/rest/ExportFormat', { dbid:, an: accession_number, format: }).body
    end

    def citation_styles(dbid:, accession_number:, styles: 'all')
      get('/edsapi/rest/CitationStyles', { dbid:, an: accession_number, styles: }).body
    end

    def search(params)
      post('/edsapi/rest/Search', params).body
    rescue Faraday::Error => e
      eds_code = e.response_body['ErrorNumber'] || e.response_body['ErrorCode']
      case eds_code
      when '138'
        # deep paging
      when '130'
        # source type nonsense
      end

      raise
    end

    def auth_token
      @auth_token ||= begin
        response = connection.post('/authservice/rest/uidauth', { UserId: eds_params[:user], Password: eds_params[:pass], InterfaceId: eds_params[:interface_id] })
        response.body['AuthToken']
      end
    end

    def session_token
      @session_token ||= begin
        response = connection.get('/edsapi/rest/CreateSession', { profile: eds_params[:profile], guest: eds_params[:guest] ? 'y' : 'n', displaydatabasename: 'y' },
                                  { 'x-authenticationToken': auth_token })

        response.body['SessionToken']
      end
    end

    private

    def get(*)
      request(:get, *)
    end

    def post(*)
      request(:post, *)
    end

    def request(method, url, params = nil, headers = nil)
      authorized_connection.public_send(method, url, params, headers)
    rescue Faraday::Error => e
      eds_code = e.response_body['ErrorNumber'] || e.response_body['ErrorCode']

      case eds_code
      when '108', '109'
        # retry once with a new session token
        session_token_retries ||= 0

        raise if session_token_retries >= 1

        session_token_retries += 1

        @session_token = nil

        retry
      when '104', '107'
        # retry once with a new auth + session token
        auth_token_retries ||= 0
        raise if auth_token_retries >= 1

        auth_token_retries += 1

        @auth_token = nil
        @session_token = nil

        retries += 1

        retry
      end

      raise
    end

    def authorized_connection
      Faraday.new(url: eds_params[:host]) do |f|
        f.headers['Accept'] = 'application/json'
        f.request :json
        f.response :raise_error
        f.response :json

        f.headers['x-sessionToken'] = session_token
        f.headers['x-authenticationToken'] = auth_token
      end
    end

    def connection
      Faraday.new(url: eds_params[:host]) do |f|
        f.headers['Accept'] = 'application/json'
        f.headers['User-Agent'] = eds_params[:user_agent]
        f.request :json
        f.response :raise_error
        f.response :json
      end
    end

    def default_session_options
      {
        guest:                        true,
        user:                         Settings.EDS_USER,
        pass:                         Settings.EDS_PASS,
        profile:                      Settings.EDS_PROFILE,
        use_cache:                    Settings.EDS_CACHE,
        eds_cache_dir:                Settings.EDS_CACHE_DIR,
        timeout:                      Settings.EDS_TIMEOUT,
        open_timeout:                 Settings.EDS_OPEN_TIMEOUT,
        host:                         Settings.EDS_HOSTS&.first,
        api_hosts_list:               Settings.EDS_HOSTS,
        debug:                        Settings.EDS_DEBUG,
        log:                          File.join(Settings.EDS_LOGDIR, 'faraday.log'),
        decode_sanitize_html:         true,
        recover_from_bad_source_type: true,
        citation_link_find:           Settings.EDS_CITATION_LINK_PATTERN,
        citation_link_replace:        Settings.EDS_CITATION_LINK_REPLACE,
        citation_db_find:             Settings.EDS_CITATION_DB_PATTERN,
        smarttext_failover:           Settings.EDS_SMARTTEXT_FAILOVER,
        interface_id: 'edsapi_ruby_gem',
        user_agent: 'EBSCO EDS GEM v0.0.1'
      }
    end
  end
end
