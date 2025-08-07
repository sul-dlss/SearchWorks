# frozen_string_literal: true

module Searchworks4
  module Item
    class BoundWithPrincipalComponent < ViewComponent::Base
      attr_reader :item, :document

      def initialize(item:, document:)
        @item = item
        @document = document

        super()
      end

      def render?
        @item.bound_with_principal? && @item.id
      end
    end
  end
end
