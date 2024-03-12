# frozen_string_literal: true

module Eds
  ##
  # A class to wrap the EBSCO::EDS::Session class.
  # We are wrapping this class so that we can easily instantiate a session object
  # without having to pass in all the session options every time (which is very versbose).
  class Session
    delegate :info, :retrieve, :search, :session_token, :solr_retrieve_list, to: :object
    def initialize(eds_params)
      @eds_params = eds_params
    end

    def object
      @object ||= EBSCO::EDS::Session.new(session_options)
    end

    private

    attr_reader :eds_params

    def session_options
      {
        guest:                        eds_params[:guest],
        session_token:                eds_params[:session_token],
        caller:                       eds_params[:caller],
        user:                         Settings.EDS_USER,
        pass:                         Settings.EDS_PASS,
        profile:                      Settings.EDS_PROFILE,
        use_cache:                    Settings.EDS_CACHE,
        eds_cache_dir:                Settings.EDS_CACHE_DIR,
        timeout:                      Settings.EDS_TIMEOUT,
        open_timeout:                 Settings.EDS_OPEN_TIMEOUT,
        api_hosts_list:               Settings.EDS_HOSTS,
        debug:                        Settings.EDS_DEBUG,
        log:                          File.join(Settings.EDS_LOGDIR, 'faraday.log'),
        decode_sanitize_html:         true,
        recover_from_bad_source_type: true,
        citation_link_find:           Settings.EDS_CITATION_LINK_PATTERN,
        citation_link_replace:        Settings.EDS_CITATION_LINK_REPLACE,
        citation_db_find:             Settings.EDS_CITATION_DB_PATTERN,
        smarttext_failover:           Settings.EDS_SMARTTEXT_FAILOVER
      }
    end
  end
end
