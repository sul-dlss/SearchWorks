# frozen_string_literal: true

module Folio
  module CirculationRules
    # Converts a parsed FOLIO circulation rules file into a set of Rule objects
    class Transform < Parslet::Transform
      # https://github.com/folio-org/mod-circulation/blob/master/doc/circulationrules.md#policies
      POLICY_TYPES = {
        'l' => 'loan',
        'r' => 'request',
        'n' => 'notice',
        'o' => 'overdue',
        'i' => 'lost-item'
      }.freeze

      # https://github.com/folio-org/mod-circulation/blob/master/doc/circulationrules.md#criteria-type-names
      CRITERIA_TYPES = {
        'g' => 'group',
        'm' => 'material-type',
        't' => 'loan-type',
        'a' => 'location-institution',
        'b' => 'location-campus',
        'c' => 'location-library',
        's' => 'location-location'
      }.freeze

      INVERTED_CRITERIA_TYPES = CRITERIA_TYPES.invert
      DEFAULT_CRITERIA = INVERTED_CRITERIA_TYPES.transform_values { |_v| '*' }

      rule(uuid: simple(:uuid)) { uuid.to_s }
      rule(type: simple(:type), uuid: simple(:uuid)) { { type: type.to_s, uuid: uuid.to_s } }
      rule(any: simple(:any)) { '*' }
      rule(letter: simple(:letter), criterium_value: subtree(:criterium_value)) do
        { letter: letter.to_s, line: letter.line_and_column.first, value: criterium_value }
      end
      rule(priority: subtree(:priority)) { { priority: priority.pluck(:criterium) } }
      rule(fallback:  subtree(:fallback)) { { fallback: fallback[:policy].to_h { |p| [POLICY_TYPES.fetch(p[:type].to_s, p[:type].to_s), p[:uuid]] } } }

      rule(criterium: subtree(:criterium), addl_criterium: subtree(:addl_criterium), indent: simple(:indent), policy: subtree(:policy)) do
        Rule.new(
          [criterium, *addl_criterium].to_h { |c| [CRITERIA_TYPES.fetch(c[:letter].to_s, c[:letter].to_s), c[:value]] },
          policy.to_h { |p| [POLICY_TYPES.fetch(p[:type].to_s, p[:type].to_s), p[:uuid]] },
          indent.to_s.length,
          criterium[:line]
        )
      end
      rule(criterium: subtree(:criterium), addl_criterium: subtree(:addl_criterium), indent: simple(:indent)) do
        Rule.new(
          [criterium, *addl_criterium].to_h { |c| [CRITERIA_TYPES.fetch(c[:letter].to_s, c[:letter].to_s), c[:value]] },
          nil,
          indent.to_s.length,
          criterium[:line]
        )
      end
      rule(headers: subtree(:headers), statement: subtree(:statement)) do
        h = headers.reduce({}, :merge)

        tree = []
        statements = statement.map do |s|
          if s[:indent].zero?
            s[:criteria] = s[:criteria]
            tree = [s]
          else
            tree.pop while tree.last[:indent] >= s[:indent]
            s[:criteria] = (tree.last&.dig(:criteria) || {}).merge(s[:criteria])
            tree << s
          end
          s
        end

        priority = h[:priority]

        sorters = priority.map do |p|
          case p
          when 'number-of-criteria'
            lambda do |policy|
              # per FOLIO docs, Any number of location criterium types (`a`, `b`, `c`, `s`) count as one.
              location_criteria, non_location_criteria = policy[:criteria].keys.partition { |k| k.start_with?('location') }
              -1 * (non_location_criteria.length + (location_criteria.any? ? 1 : 0))
            end
          when 'first-line'
            ->(policy) { policy[:line] }
          when 'last-line'
            ->(policy) { -1 * policy[:line] }
          when Array
            order = p.pluck(:letter).reverse
            lambda do |policy|
              # per FOLIO docs, we only consider the first matching criteria type
              policy[:criteria].keys.map { |x| order.index(INVERTED_CRITERIA_TYPES.fetch(x, x)) || INVERTED_CRITERIA_TYPES.length }
            end
          end
        end

        statements = statements.sort_by { |s| sorters.map { |z| z.call(s) } }
        statements = statements.map do |s|
          s.criteria = DEFAULT_CRITERIA.merge(s[:criteria])
          s
        end

        statements = statements.reject { |s| s[:policy].nil? } + [Rule.new(DEFAULT_CRITERIA, h[:fallback], 0, 0)]

        statements
      end
    end
  end
end
