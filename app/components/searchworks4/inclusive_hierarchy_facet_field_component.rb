# frozen_string_literal: true

module Searchworks4
  class InclusiveHierarchyFacetFieldComponent < Blacklight::Hierarchy::FacetFieldComponent
    # The original inclusive component ONLY renders the values that were passed
    # in as inclusive. We want to change this to be all values

    def initialize(values:, field_name:, tree:, key:)
      @values = values
      super(field_name:, tree:, key:)
    end
   
    # Facet field values are an array of arrays
    def qfacet_selected?
      @values.any? { |v| v.include?(item.qvalue) }
    end
  end
end
