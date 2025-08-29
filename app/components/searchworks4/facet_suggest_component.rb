# frozen_string_literal: true

module Searchworks4
  class FacetSuggestComponent < Blacklight::Facets::SuggestComponent
    def suggest_query
      params["facet_suggest_query"] || nil
    end
  end
end
