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
      eds_session = Eds::Session.new(eds_params.update(caller: 'bl-repo-find-by-ids'))
      results = eds_session.solr_retrieve_list(list: ids)
      blacklight_config.response_model.new(
        results,
        {},
        document_model: blacklight_config.document_model,
        blacklight_config:
      )
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
        results = eds_results_with_date_range(eds_session.search(bl_params).to_solr)
      end
      blacklight_config.response_model.new(results,
                                           bl_params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config:)
    end

    def eds_find(id, params, eds_params)
      dbid = id.split('__', 2).first
      accession = id.split('__', 2).last.gsub('%2F', '/')
      eds_session = Eds::Session.new(eds_params.update(caller: 'bl-repo-find'))
      record = eds_session.retrieve(dbid:, an: accession)
      blacklight_config.response_model.new(record.to_solr,
                                           params,
                                           document_model: blacklight_config.document_model,
                                           blacklight_config:)
    end

    # Some data providers in EDS don't have the data that populates the pub_year_tisim field
    # (although we can query against the data), so this forces the pub_year_tisim field to be populated
    # when the response from EDS still contains date range data.
    # https://github.com/sul-dlss/SearchWorks/issues/1721
    def eds_results_with_date_range(results)
      return results if results.dig('facet_counts', 'facet_fields', 'pub_year_tisim').present?
      return results unless results.key?('date_range')

      results['facet_counts']['facet_fields']['pub_year_tisim'] = [
        results['date_range'][:minyear],
        results['date_range'][:maxyear]
      ]

      results
    end
  end
end
