# frozen_string_literal: true

require 'blacklight_advanced_search/advanced_search_builder'

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightRangeLimit::RangeLimitBuilder
  include CJKQuery

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  self.default_processor_chain += [:database_prefix_search]
  self.default_processor_chain += [:modify_params_for_cjk, :modify_params_for_cjk_advanced]
  self.default_processor_chain += [:consolidate_home_page_params]
  self.default_processor_chain += [:modify_single_term_qf]

  # Override range limit to only add parameters on search pages, not the home page
  def add_range_limit_params(*args)
    super unless on_home_page?
  end

  def consolidate_home_page_params(solr_params)
    return unless on_home_page?

    solr_params['facet.field'] = ['access_facet', 'format_main_ssim', 'building_facet', 'language']
    solr_params['rows'] = 0
  end

  def database_prefix_search(solr_params)
    return unless page_location.databases? &&
                  blacklight_params[:prefix] &&
                  blacklight_params[:prefix].match?(/^(0-9|[a-z])$/i)

    solr_params[:fq] ||= []
    solr_params[:fq] << "title_sort:/[#{blacklight_params[:prefix]}].*/"
  end

  # Solr edismax does not apply phrase boosts to single-term matches. When we have a single term query,
  # we can use a different set of query boosts to give better results.
  def modify_single_term_qf(solr_params)
    return unless blacklight_params && blacklight_params[:q].present? && solr_params[:qf].blank?

    q_str = blacklight_params[:q]
    return unless q_str.split.size == 1

    solr_params[:qf] = '${qf_single_term}'
  end

  private

  def page_location
    @page_location ||= PageLocation.new(search_state)
  end

  def on_home_page?
    return false unless search_state.controller&.action_name == 'index' && search_state.controller.controller_name == 'catalog'

    blacklight_params[:q].blank? && blacklight_params[:f].blank? && blacklight_params[:search_field].blank? && blacklight_params[:clause].blank?
  end
end
