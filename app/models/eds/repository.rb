module Eds
  class Repository < Blacklight::AbstractRepository
    ##
    # Execute a search against EDS
    #
    def search(search_builder = {}, eds_params = {})
      send_and_receive(blacklight_config.solr_path, search_builder, eds_params)
    end

    def send_and_receive(path, search_builder = {}, eds_params = {})
      benchmark('EDS fetch', level: :info) do

        # results list passes a full searchbuilder, detailed record only passes params
        bl_params = search_builder.is_a?(SearchBuilder) ? search_builder.blacklight_params : search_builder
        # TODO: make highlighting configurable
        bl_params = bl_params.update('hl' => 'on')

        eds = EBSCO::EDS::Session.new(eds_options(eds_params.update(caller: 'bl-search')))
        if eds_params['previous-next-index']
          # [1] NEXT-PREVIOUS
          bl_params.update('previous-next-index' => eds_params['previous-next-index'])
          results = eds.solr_retrieve_previous_next(bl_params)
        elsif  bl_params && bl_params['q'] && bl_params['q']['id']
          # [2] LIST OF IDS (e.g., bookmarks, email, sms, cite)
          results = eds.solr_retrieve_list(list: bl_params['q']['id'])
        else
          # [3] REGULAR SEARCH
          results = eds.search(bl_params).to_solr
        end
        blacklight_config.response_model.new(results, bl_params,
                                             document_model: blacklight_config.document_model,
                                             blacklight_config: blacklight_config)
      end
    end

    # Construct EDS Session options
    def eds_options(eds_params = {})
      {
        guest: eds_params['guest'],
        session_token: eds_params['session_token'],
        caller: eds_params[:caller],
        user: Settings.EDS_USER,
        pass: Settings.EDS_PASS,
        profile: Settings.EDS_PROFILE,
        debug: Settings.EDS_DEBUG
      }
    end

    def find(id, params = {}, eds_params = {})
      eds = EBSCO::EDS::Session.new(eds_options(eds_params.update(caller: 'bl-repo-find')))
      dbid = id.split('__').first
      accession = id.split('__').last
      accession.gsub!(/_/, '.')
      record = eds.retrieve(dbid: dbid, an: accession)
      solr_result = record.to_solr
      blacklight_config.response_model.new(solr_result, params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config: blacklight_config)
    end
  end
end
