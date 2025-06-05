# frozen_string_literal: true

module Articles
  class SearchNavbarComponent < Blacklight::SearchNavbarComponent
    def search_bar_component
      search_bar_component_class.new(
        url: helpers.search_action_url,
        # advanced_search_url: helpers.search_action_url(action: 'advanced_search'),
        params: helpers.search_state.params_for_search.except(:qt)
        # autocomplete_path: suggest_index_catalog_path
      )
    end
  end
end
