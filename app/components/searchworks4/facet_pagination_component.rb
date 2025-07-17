# frozen_string_literal: true

module Searchworks4
  class FacetPaginationComponent < Blacklight::FacetFieldPaginationComponent
    def sort
      @facet_field.paginator.sort
    end
  end
end
