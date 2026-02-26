# frozen_string_literal: true

module Record
  module Cocina
    class AbstractContentsComponent < ViewComponent::Base
      def initialize(document:)
        super()
        @document = document
      end

      attr_reader :document

      delegate :cocina_display, to: :document

      def fields
        @fields ||= cocina_display.abstract_display_data + cocina_display.table_of_contents_display_data
      end

      def render?
        fields.present?
      end
    end
  end
end
