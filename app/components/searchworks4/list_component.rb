# frozen_string_literal: true

module Searchworks4
  class ListComponent < Blacklight::Facets::ListComponent
    def inclusive_present?
      @facet_field.values.find { |v| v.is_a? Array }
    end
  end
end
