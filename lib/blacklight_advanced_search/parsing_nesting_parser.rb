require 'parsing_nesting/tree'
module BlacklightAdvancedSearch
  # Monkypatch ParsingNestingParser to pass config to ParsingNesting::Tree.parse
  # We can remove if https://github.com/projectblacklight/blacklight_advanced_search/pull/25
  # is accepted and a release is cut.
  module ParsingNestingParser
    def process_query(params,config)
      queries = []
      keyword_queries.each do |field,query| 
        queries << ParsingNesting::Tree.parse(query, config.advanced_search[:query_parser]).to_query( local_param_hash(field, config) )
      end
      queries.join( ' ' + keyword_op + ' ')
    end

    def local_param_hash(key, config)
      field_def = config.search_fields[key]

      (field_def[:solr_parameters] || {}).merge(field_def[:solr_local_parameters] || {})
    end
  end
end
