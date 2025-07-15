# frozen_string_literal: true

module Searchworks4
  class ThesesDissertationFacetHeaderComponent < ViewComponent::Base
    delegate :search_state, :add_filter_unless_present, :remove_filter_if_present, to: :helpers

    def theses_stanford_only_path
      state = search_state.deep_dup
      state = add_filter_unless_present(state, 'stanford_work_facet_hsim', 'Thesis/Dissertation')
      search_catalog_path(state.to_h)
    end

    def theses_all_path
      state = search_state.deep_dup
      state = remove_filter_if_present(state, 'stanford_work_facet_hsim', 'Thesis/Dissertation')
      search_catalog_path(state.to_h)
    end

    # Don't let rubocop change values.include? to .values?
    # rubocop:disable Performance/InefficientHashSearch
    def stanford_only_selected?
      state = search_state.deep_dup
      state.filter('stanford_work_facet_hsim').values.include?('Thesis/Dissertation')
    end
    # rubocop:enable Performance/InefficientHashSearch
  end
end
