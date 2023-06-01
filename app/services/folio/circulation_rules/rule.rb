# frozen_string_literal: true

module Folio
  module CirculationRules
    # A circulation rule that applies a policy when its criteria are met
    Rule = Struct.new(:criteria, :policy, :indent, :line, :priority) do
      include Comparable

      def self.type_debug_string
        {
          'group' => ->(v) { Folio::Types.criteria['group']&.dig(v, 'group') || v },
          'material-type' => ->(v) { Folio::Types.criteria['material-type']&.dig(v, 'name') || v },
          'loan-type' => ->(v) { Folio::Types.criteria['loan-type']&.dig(v, 'name') || v },
          'location-institution' => ->(v) { Folio::Types.criteria['location-institution']&.dig(v, 'code') || v },
          'location-campus' => ->(v) { Folio::Types.criteria['location-campus']&.dig(v, 'code') || v },
          'location-library' => ->(v) { Folio::Types.criteria['location-library']&.dig(v, 'code') || v },
          'location-location' => ->(v) { Folio::Types.criteria['location-location']&.dig(v, 'code') || v }
        }
      end

      # Rules are sorted by priority
      def <=>(other)
        priority <=> other.priority
      end

      # e.g.
      # ```
      # group: faculty & material-type: periodical & loan-type: any & location-institution: any & location-campus: any & location-library: SAL & location-location: any => loan: 14day-1renew-1daygrace, request: Allow All, notice: Short-term loans, overdue: No fines policy, lost-item: $100 lost fee policy (line 257)
      # ```
      def to_debug_s
        "#{to_criteria_debug_s} => #{to_policy_debug_s} (line #{line})"
      end

      private

      def to_criteria_debug_s
        criteria.map do |k, v|
          type_map = self.class.type_debug_string[k] || ->(uuid) { uuid }

          debug_value = case v
                        when '*'
                          'any'
                        when Hash
                          v[:or].map { |uuid| type_map.call(uuid) }.join(' or ')
                        else
                          type_map.call(v)
                        end
          "#{k}: #{debug_value}"
        end.join(" & ")
      end

      def to_policy_debug_s
        policy.map { |k, v| "#{k}: #{Folio::Types.policies.dig(k.to_sym, v, 'name')&.strip || v}" }.join(", ")
      end
    end
  end
end
