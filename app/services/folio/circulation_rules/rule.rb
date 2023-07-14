# frozen_string_literal: true

require 'csv'

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
        "#{to_criteria_debug_s}\n#{to_policy_debug_s}\n(line #{line})"
      end

      def to_csv
        CSV.generate_line [
          criteria_name('group'),
          criteria_name('material-type'),
          criteria_name('loan-type'),
          criteria_name('location-institution'),
          criteria_name('location-campus'),
          criteria_name('location-library'),
          criteria_name('location-location'),
          policy_name('loan'),
          policy_name('request'),
          policy_name('notice'),
          policy_name('overdue'),
          policy_name('lost-item'),
          line,
          priority
        ]
      end

      private

      def to_criteria_debug_s
        criteria.map do |k, _v|
          "#{k}: #{criteria_name(k)}"
        end.join("\n")
      end

      def to_policy_debug_s
        policy.map { |k, _v| "=> #{k}: #{policy_name(k)}" }.join("\n")
      end

      def criteria_name(key)
        value = criteria[key]

        type_map = self.class.type_debug_string[key] || ->(uuid) { uuid }

        case value
        when '*'
          'any'
        when Hash
          value[:or].map { |uuid| type_map.call(uuid) }.join(' or ')
        else
          type_map.call(value)
        end
      end

      def policy_name(key)
        Folio::Types.policies.dig(key.to_sym, policy[key], 'name')&.strip || policy[key]
      end
    end
  end
end
