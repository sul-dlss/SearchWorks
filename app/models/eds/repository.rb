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
      eds_session = Eds::Session.new(eds_params.update(caller: 'bl-search'))
      bl_params = search_builder.to_hash

      if bl_params.try(:dig, 'q').try(:dig, 'id')
        # List of ID's
        results = eds_session.solr_retrieve_list(list: bl_params['q']['id'])
      else
        # Regular search
        results = eds_session.search(bl_params).to_solr
      end
      blacklight_config.response_model.new(results,
                                           bl_params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config: blacklight_config)
    end

    def eds_find(id, params, eds_params)
      dbid = id.split('__', 2).first
      accession = id.split('__', 2).last
      eds_session = Eds::Session.new(eds_params.update(caller: 'bl-repo-find'))
      record = eds_session.retrieve(dbid: dbid, an: accession)
      blacklight_config.response_model.new(record.to_solr,
                                           params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config: blacklight_config)
    end
  end
end
