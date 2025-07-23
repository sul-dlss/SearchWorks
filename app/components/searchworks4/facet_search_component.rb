# frozen_string_literal: true

module Searchworks4
  class FacetSearchComponent < Searchworks4::ListComponent
    # Used to extend: Blacklight::Facets::ListComponent
    def search_url
      helpers.catalog_facet_results_path(id: facet_field.key)
    end

    class FacetPresenterWithoutModal < SimpleDelegator
      def modal_path; end
    end

    # Override to remove the "more" link from the facet field.
    # This is a placeholder method; actual implementation may vary.

    def facet_field_without_more_link
      FacetPresenterWithoutModal.new(@facet_field)
    end
  end
end
