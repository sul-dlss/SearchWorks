# frozen_string_literal: true

module SearchResult
  module NoResult
    class FiltersComponent < Blacklight::ConstraintsComponent
      def query_constraints; end

      def render?
        @search_state.filters.present? || @search_state.clause_params.present?
      end
    end
  end
end
