# frozen_string_literal: true

module Searchworks
  # Override blacklight_advanced_search to support our custom advanced search form.
  module AdvancedSearchBuilder
    # Override the upstream query parser to inject the any/all logic
    class SearchworksAdvancedSearchQueryParser < BlacklightAdvancedSearch::QueryParser
      def process_query(config)
        queries = keyword_queries.map do |clause|
          field = clause[:field]
          query = clause[:query]

          local_params = local_param_hash(field, config)

          if clause[:type] == 'any'
            local_params[:'q.op'] = 'OR'
            local_params[:mm] = 0
          end

          ParsingNesting::Tree.parse(query, config.advanced_search[:query_parser]).to_query(local_params)
        end
        queries.join(" #{keyword_op} ")
      end
    end

    # Override the upstream adv. search implementation to use our own query parser
    def add_adv_search_clauses(solr_parameters)
      return unless is_advanced_search?

      # If we've got the hint that we're doing an 'advanced' search, then
      # map that to solr #q, over-riding whatever some other logic may have set, yeah.
      advanced_query = SearchworksAdvancedSearchQueryParser.new(search_state, blacklight_config)
      BlacklightAdvancedSearch.deep_merge!(solr_parameters, advanced_query.to_solr)
      return if advanced_query.keyword_queries.empty?

      # force :qt if set, fine if it's nil, we'll use whatever CatalogController
      # ordinarily uses.
      solr_parameters[:qt] = blacklight_config.advanced_search[:qt]
      solr_parameters[:defType] = "lucene"
    end
  end
end
