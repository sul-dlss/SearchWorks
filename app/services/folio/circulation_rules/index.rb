# frozen_string_literal: true

module Folio
  module CirculationRules
    # A simple rule index that iterates through rules to find the first match
    #
    # NOTE: this is a naive implementation, but it performed better than others
    # in testing. If performance becomes an issue, we can look at other options.
    #
    # For details and benchmarking/helper scripts, as well as other options, see:
    # https://gist.github.com/thatbudakguy/fb15100375d9c12ee469488021344adb
    class Index
      def initialize(rules)
        @rules = []

        # If rules don't have a priority, assign them one based on their order
        rules.each_with_index do |rule, index|
          rule.priority ||= index
          @rules << rule
        end
      end

      # Iterate through the rules in order, returning the first one that matches
      # the search criteria. If no rules match, return the fallback rule
      def search(search_criteria)
        @rules.find(proc { @rules.max }) do |rule|
          positive_match?(rule, search_criteria) && !negative_match?(rule, search_criteria)
        end
      end

      private

      # Rules are excluded if any of their negative criteria match the search criteria
      def negative_match?(rule, search_criteria)
        rule.criteria.any? do |criterium, values|
          values.is_a?(Hash) && values[:not]&.any?(search_criteria[criterium])
        end
      end

      # Rules are included if all of their positive criteria match the search criteria
      def positive_match?(rule, search_criteria)
        rule.criteria.all? do |criterium, values|
          values = case values
                   when Hash
                     values[:or] || []
                   when String
                     [values]
                   else
                     values
                   end

          # Always treat 'group' criterium (ignored) and the wildcard as matching
          criterium == 'group' || values == ['*'] || values.any?(search_criteria[criterium])
        end
      end
    end
  end
end
