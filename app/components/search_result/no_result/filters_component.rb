# frozen_string_literal: true

module SearchResult
  module NoResult
    class FiltersComponent < Blacklight::ConstraintsComponent
      def render?
        !(@search_state.filters.blank? && @search_state.clause_params.blank?)
      end
    end
  end
end
