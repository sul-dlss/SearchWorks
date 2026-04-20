# frozen_string_literal: true

module Record
  module Cocina
    # Component for displaying related resources. Renders a simple link if a
    # URL is present, otherwise uses the nested item presentation.
    class RelatedResourceComponent < ViewComponent::Base
      def initialize(related_resource:)
        super()
        @related_resource = related_resource
      end

      attr_reader :related_resource

      def render?
        related_resource.present?
      end
    end
  end
end
