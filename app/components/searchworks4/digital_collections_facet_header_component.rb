# frozen_string_literal: true

module Searchworks4
  class DigitalCollectionsFacetHeaderComponent < ViewComponent::Base
    delegate :page_location, :search_state, :add_filter_unless_present, :remove_filter_if_present, to: :helpers

    def digital_all_items_path
      state = search_state.deep_dup

      state = remove_filter_if_present(state, 'collection_type', 'Digital Collection')
      state = add_filter_unless_present(state, 'library', 'SDR')

      search_catalog_path(state.to_h)
    end

    def digital_collections_only_path
      state = search_state.deep_dup

      state = remove_filter_if_present(state, 'library', 'SDR')
      state = add_filter_unless_present(state, 'collection_type', 'Digital Collection')

      search_catalog_path(state.to_h)
    end
  end
end
