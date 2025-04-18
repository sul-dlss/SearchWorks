# frozen_string_literal: true

module SearchResult
  module NoResult
    class FiltersComponent < Blacklight::ConstraintsComponent
      def query_constraints; end
    end
  end
end
