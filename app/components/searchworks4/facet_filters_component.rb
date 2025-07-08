# frozen_string_literal: true

module Searchworks4
  class FacetFiltersComponent < Blacklight::Facets::FiltersComponent
    def initialize(suggestions_component: Searchworks4::FacetSuggestComponent, classes: [], **)
      super(**, classes: classes, suggestions_component: suggestions_component)
    end
  end
end
