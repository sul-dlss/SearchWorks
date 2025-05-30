# frozen_string_literal: true

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

    def find_by_ids(ids, eds_params = {})
      results = connection.solr_retrieve_list(list: ids)
      blacklight_config.response_model.new(
        results,
        {},
        document_model: blacklight_config.document_model,
        blacklight_config:
      )
    end

    private

    def eds_search(search_builder = {}, eds_params = {})
      bl_params = search_builder.to_hash

      if bl_params.dig('q', 'id')
        # List of ID's
        results = find_by_ids(Array(bl_params.dig('q', 'id')))
      else
        # Regular search
        results = connection.search(bl_params)
      end
      blacklight_config.response_model.new(results,
                                           search_builder,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config:)
    end

    def eds_find(id, params, eds_params)
      dbid = id.split('__', 2).first
      accession = id.split('__', 2).last.gsub('%2F', '/')
      record = connection.retrieve(dbid:, an: accession)
      blacklight_config.response_model.new(record,
                                           params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config:)
    end

    def build_connection
      Eds::Session.new({})
    end
  end
end
