# frozen_string_literal: true

module Folio
  module CirculationRules
    CIRC_RULES_FILE_PATH = Rails.root.join('config/circulation_rules.txt').freeze

    class PolicyService
      # Load the circulation rules file and parse it into a set of ordered rules
      def self.rules
        rules = Folio::CirculationRules::Transform.new.apply(Folio::CirculationRules::Parser.new.parse(CIRC_RULES_FILE_PATH.read))
        rules.map.with_index do |rule, index|
          rule.priority = index
          rule
        end
      end

      # Provide custom rules or use the default set
      def initialize(rules: nil)
        @index = Folio::CirculationRules::Index.new(rules || self.class.default_rules)
      end

      # Find the circulation rule that applies to the given Holdings::Item
      def item_rule(item)
        @index.search('material-type' => item.material_type.id,
                      'loan-type' => item.loan_type.id,
                      'location-institution' => item.effective_location.institution.id,
                      'location-campus' => item.effective_location.campus.id,
                      'location-library' => item.effective_location.library.id,
                      'location-location' => item.effective_location.id)
      end
    end
  end
end
