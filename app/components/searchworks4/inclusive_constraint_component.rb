# frozen_string_literal: true

module Searchworks4
  class InclusiveConstraintComponent < Blacklight::Facets::InclusiveConstraintComponent
    # The original inclusive component ONLY renders the values that were passed
    # in as inclusive. We want to change this to be all values
    def values
      @values ||= @facet_field.values.find { |v| v.is_a? Array }
      @values || []
    end

    def presenters
      # Note that the values returned are the ones that are POSSIBLE with the search
      # This will not list the inclusive value if it isn't included in the facets
      @facet_field.paginator.items.map do |item|
        AdvancedFacetItemPresenter.new(values, item, @facet_field.facet_field, helpers, @facet_field.key, @facet_field.search_state)
      end
    end
  end
end
