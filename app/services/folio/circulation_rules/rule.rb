# frozen_string_literal: true

module Folio
  module CirculationRules
    # A circulation rule that applies a policy when its criteria are met
    Rule = Struct.new(:criteria, :policy, :indent, :line, :priority) do
      include Comparable

      # Rules are sorted by priority
      def <=>(other)
        priority <=> other.priority
      end
    end
  end
end
