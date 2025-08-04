# frozen_string_literal: true

module Searchworks4
  module Item
    class BoundWithParentComponent < ViewComponent::Base
      attr_reader :item, :document

      def initialize(item:, document:)
        @item = item
        @document = document

        super()
      end

      def render?
        item.bound_with_parent.present?
      end

      def document_bound_with_item?
        item.bound_with_id == document.id
      end

      def bound_with_title
        item.bound_with_parent['title']
      end

      def bound_with_callnumber
        [item.bound_with_parent['call_number'], item.bound_with_parent['volume'],
         item.bound_with_parent['enumeration'], item.bound_with_parent['chronology']].compact.join(' ')
      end
    end
  end
end
