# frozen_string_literal: true

module Searchworks4
  class FormatFacetComponent < Blacklight::Hierarchy::FacetFieldListComponent

    def inclusive_present?
      @facet_field.values.find { |v| v.is_a? Array }
    end
  end
end
