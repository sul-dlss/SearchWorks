# frozen_string_literal: true

module Searchworks
  # Override blacklight (+ blacklight_advanced_search) to support our custom advanced search form.
  module AdvancedSearchBuilder
    # Transform "clause" parameters into the Solr JSON Query DSL
    def add_adv_search_clauses(solr_parameters)
      search_state.clause_params&.each_value do |clause|
        next if clause[:query].blank?

        field = (blacklight_config.search_fields || {})[clause[:field]] if clause[:field]

        field_params = field.solr_parameters || {}
        field_params = field_params.merge(field.cjk_solr_parameters) if cjk_unigrams_size(clause[:query]).positive? && field&.cjk_solr_parameters
        field_params = field_params.merge('q.op': 'OR', mm: 0) if clause[:type] == 'any'

        query = {
          edismax: field_params.merge(query: clause[:query])
        }

        solr_parameters.append_boolean_query(:must, query)
      end
    end
  end
end
