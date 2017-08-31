module Eds
  class Repository < Blacklight::AbstractRepository
    def search(search_builder = {}, eds_params = {})
      benchmark('EDS search', level: :info) do
        eds_search(search_builder, eds_params)
      end
    end

    def find(id, params = {}, eds_params = {})
      benchmark('EDS find', level: :info) do
        eds_find(id, params, eds_params)
      end
    end

    private

    def eds_search(search_builder = {}, eds_params = {})
      eds_session = EBSCO::EDS::Session.new(eds_session_options(eds_params.update(caller: 'bl-search')))
      bl_params = search_builder.to_hash
      results = eds_session.search(bl_params).to_solr
      blacklight_config.response_model.new(results,
                                           bl_params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config: blacklight_config)
    end

    def eds_find(id, params, eds_params)
      dbid = id.split('__', 2).first
      accession = id.split('__', 2).last.tr('_', '.')
      eds_session = EBSCO::EDS::Session.new(eds_session_options(eds_params.update(caller: 'bl-repo-find')))
      record = eds_session.retrieve(dbid: dbid, an: accession)
      blacklight_config.response_model.new(record.to_solr,
                                           params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config: blacklight_config)
    end

    def eds_session_options(eds_params = {})
      {
        guest:          eds_params[:guest],
        session_token:  eds_params[:session_token],
        caller:         eds_params[:caller],
        user:           Settings.EDS_USER,
        pass:           Settings.EDS_PASS,
        profile:        Settings.EDS_PROFILE,
        use_cache:      Settings.EDS_CACHE,
        eds_cache_dir:  Settings.EDS_CACHE_DIR,
        timeout:        Settings.EDS_TIMEOUT,
        open_timeout:   Settings.EDS_OPEN_TIMEOUT,
        api_hosts_list: Settings.EDS_HOSTS,
        debug:          Settings.EDS_DEBUG,
        log:            File.join(Settings.EDS_LOGDIR, 'faraday.log')
      }
    end
  end
end
