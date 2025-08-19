# frozen_string_literal: true

module Searchworks4
  class NegativeConstraintPresenter < SimpleDelegator
    # This method returns what to display for the inclusive facet constraint
    # preceding the title and value of the facet.
    def prefix
      'Excludes <span class="fw-bold">ALL</span>'
    end
  end
end
