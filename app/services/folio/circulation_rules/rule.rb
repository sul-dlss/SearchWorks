# frozen_string_literal: true

require 'csv'

module Folio
  module CirculationRules
    # A circulation rule that applies a policy when its criteria are met
    Rule = Struct.new(:criteria, :policy, :indent, :line, :priority) do
      include Comparable

      def self.type_debug_string
        {
          'group' => ->(v) { Folio::Types.criteria['group']&.dig(v, 'group') },
          'material-type' => ->(v) { Folio::Types.criteria['material-type']&.dig(v, 'name') },
          'loan-type' => ->(v) { Folio::Types.criteria['loan-type']&.dig(v, 'name') },
          'location-institution' => ->(v) { Folio::Types.criteria['location-institution']&.dig(v, 'code') },
          'location-campus' => ->(v) { Folio::Types.criteria['location-campus']&.dig(v, 'code') },
          'location-library' => ->(v) { Folio::Types.criteria['location-library']&.dig(v, 'code') },
          'location-location' => ->(v) { Folio::Types.criteria['location-location']&.dig(v, 'code') }
        }
      end

      # Rules are sorted by priority
      def <=>(other)
        priority <=> other.priority
      end

      # e.g.
      # ```
      # group: faculty
      # material-type: any
      # loan-type: 4-hour reserve
      # location-campus: SUL
      # => loan: 4hour-norenew-15mingrace
      # => request: No requests allowed
      # => notice: Course reserves
      # => overdue: No fines
      # => lost-item: $230 reserves lost fee
      # (line 334)
      # ```
      def to_debug_s
        "#{to_criteria_debug_s}\n#{to_policy_debug_s}\n(line #{line})"
      end

      # @param include_line_metadata [Boolean] Include the line number and priority in the CSV output; it's necessary to omit line metadata
      #                              when comparing two sets of rules, but it's helpful to include it when debugging within a single set of rules
      def to_csv(include_line_metadata: false)
        CSV.generate_line([
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
          policy_name('lost-item')
        ] + (include_line_metadata ? [line, priority] : []))
      end

      private

      def to_criteria_debug_s
        criteria.compact.map do |k, _v|
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
        when Hash
          value[:or].map { |uuid| type_map.call(uuid) || uuid }.join(' or ')
        else
          type_map.call(value) || value
        end
      end

      def policy_name(key)
        Folio::Types.policies.dig(key.to_sym, policy[key], 'name')&.strip || policy[key]
      end
    end
  end
end
