class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightRangeLimit::RangeLimitBuilder
  include CJKQuery

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  self.default_processor_chain += [:database_prefix_search]
  self.default_processor_chain += [:modify_params_for_cjk, :modify_params_for_cjk_advanced]

  def database_prefix_search(solr_params)
    if page_location.access_point.databases? && blacklight_params[:prefix]
      if blacklight_params[:prefix] == "0-9"
        query = ("0".."9").map do |number|
          "title_sort:#{number}*"
        end.join(" OR ")
      else
        query = "title_sort:#{blacklight_params[:prefix]}*"
      end
      solr_params[:qt] = blacklight_config.lucene_req_handler
      solr_params[:q] = [query, blacklight_params[:q]].compact.join(" AND ")
    end
  end

  def modifiable_params_keys
    %w[q search search_author search_title subject_terms series_search pub_search isbn_search]
  end

  private

  def page_location
    SearchWorks::PageLocation.new(blacklight_params)
  end
end
