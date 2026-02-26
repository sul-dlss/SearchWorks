# frozen_string_literal: true

module Record
  module Cocina
    class ContributorsComponent < ViewComponent::Base
      def initialize(document:)
        super()
        @document = document
      end

      attr_reader :document

      delegate :cocina_display, to: :document
      delegate :contributor_display_data, to: :cocina_display

      def render?
        contributor_display_data.present?
      end
    end
  end
end
