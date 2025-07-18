# frozen_string_literal: true

module Searchworks4
  class InclusiveFacetItemPresenter < Blacklight::InclusiveFacetItemPresenter
    # This method returns what to display for the inclusive facet constraint
    # preceding the title and value of the facet.
    def prefix
      'Includes <span class="fw-bold">ANY</span>'
    end
  end
end
