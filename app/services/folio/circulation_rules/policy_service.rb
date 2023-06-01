# frozen_string_literal: true

module Folio
  module CirculationRules
    CIRC_RULES_FILE_PATH = Rails.root.join('config/circulation_rules.txt').freeze
    REQUEST_POLICY_FILE_PATH = Rails.root.join('config/request_policies.json').freeze
    LOAN_POLICY_FILE_PATH = Rails.root.join('config/loan_policies.json').freeze
    OVERDUE_POLICY_FILE_PATH = Rails.root.join('config/overdue_policies.json').freeze
    LOST_POLICY_FILE_PATH = Rails.root.join('config/lost_policies.json').freeze
    NOTICE_POLICY_FILE_PATH = Rails.root.join('config/notice_policies.json').freeze

    class PolicyService
      # Load the circulation rules file and parse it into a set of ordered rules
      def self.rules
        rules = Folio::CirculationRules::Transform.new.apply(Folio::CirculationRules::Parser.new.parse(CIRC_RULES_FILE_PATH.read))
        rules.map.with_index do |rule, index|
          rule.priority = index
          rule
        end
      end

      # Load policy definitions from static JSON files and index by UUID
      def self.policies
        {
          request: JSON.parse(REQUEST_POLICY_FILE_PATH.read).index_by { |p| p['id'] },
          loan: JSON.parse(LOAN_POLICY_FILE_PATH.read).index_by { |p| p['id'] },
          overdue: JSON.parse(OVERDUE_POLICY_FILE_PATH.read).index_by { |p| p['id'] },
          'lost-item': JSON.parse(LOST_POLICY_FILE_PATH.read).index_by { |p| p['id'] },
          notice: JSON.parse(NOTICE_POLICY_FILE_PATH.read).index_by { |p| p['id'] }
        }
      end

      attr_reader :index, :policies

      # Provide custom rules and policies or use the defaults
      def initialize(rules: nil, policies: nil)
        @index = Folio::CirculationRules::Index.new(rules || self.class.rules)
        @policies = policies || self.class.policies
      end

      # Return the request policy for the given Holdings::Item
      def item_request_policy(item)
        rule = item_rule(item)
        @policies[:request].fetch(rule.policy['request'], nil)
      end

      # Return the loan policy for the given Holdings::Item
      def item_loan_policy(item)
        rule = item_rule(item)
        @policies[:loan].fetch(rule.policy['loan'], nil)
      end

      # Return the overdue fine policy for the given Holdings::Item
      def item_overdue_policy(item)
        rule = item_rule(item)
        @policies[:overdue].fetch(rule.policy['overdue'], nil)
      end

      # Return the lost item policy for the given Holdings::Item
      def item_lost_policy(item)
        rule = item_rule(item)
        @policies[:'lost-item'].fetch(rule.policy['lost-item'], nil)
      end

      # Return the patron notice policy for the given Holdings::Item
      def item_notice_policy(item)
        rule = item_rule(item)
        @policies[:notice].fetch(rule.policy['notice'], nil)
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
