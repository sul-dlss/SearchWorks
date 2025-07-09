# frozen_string_literal: true

module Eds
  class Repository < Blacklight::AbstractRepository
    def initialize(blacklight_config, eds_params: {})
      super(blacklight_config)
      @eds_params = eds_params
    end

    def search(search_builder = {})
      benchmark('EDS search', level: :info) do
        eds_search(search_builder)
      end
    end

    def find(id, params = {})
      benchmark('EDS find', level: :info) do
        eds_find(id, params)
      end
    end

    def find_by_ids(ids, params = {})
      ids.map do |id|
        find(id, params)
      end
    end

    delegate :session_token, to: :connection

    private

    def eds_search(search_builder = {})
      bl_params = search_builder.to_hash

      # Regular search
      results = connection.search(bl_params)
      blacklight_config.response_model.new(results,
                                           search_builder,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config:)
    end

    def eds_find(id, _params)
      dbid = id.split('__', 2).first
      accession_number = id.split('__', 2).last.gsub('%2F', '/')
      record = connection.retrieve(dbid:, accession_number: accession_number)
      blacklight_config.document_model.new(record)
    end

    def build_connection
      Eds::Session.new(**@eds_params)
    end
  end
end
