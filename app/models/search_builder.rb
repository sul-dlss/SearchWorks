class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightRangeLimit::RangeLimitBuilder
  include CJKQuery

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  self.default_processor_chain += [:modify_params_for_cjk, :modify_params_for_cjk_advanced]

  def modifiable_params_keys
    %w[q search search_author search_title subject_terms series_search pub_search isbn_search]
  end

  private

  def page_location
    SearchWorks::PageLocation.new(blacklight_params)
  end
end
