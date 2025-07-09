# frozen_string_literal: true

module Searchworks4
  class FacetSearchResultComponent < Blacklight::Facets::ListComponent
    def initialize(id: nil, classes: [], **)
      super(**)
      @id = id
      @classes = classes
    end

    def facet_item_presenters
      super.reject(&:selected?)
    end

    def render?
      true
    end
  end
end
