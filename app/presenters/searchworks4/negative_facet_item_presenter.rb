# frozen_string_literal: true

module Searchworks4
  class NegativeFacetItemPresenter < Blacklight::FacetItemPresenter
    # This method returns what to display for the inclusive facet constraint
    # preceding the title and value of the facet.
    def prefix
      'Excludes <span class="fw-bold">ALL</span>'
    end
  end
end
