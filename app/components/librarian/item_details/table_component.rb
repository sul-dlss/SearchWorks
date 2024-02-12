# frozen_string_literal: true

module Librarian
  module ItemDetails
    class TableComponent < ViewComponent::Base
      Location = Data.define(:items, :permanent_location_code, :label)
      Item = Data.define(:call_number, :barcode, :location)

      def initialize(document:)
        @document = document
        super()
      end

      attr_reader :document

      delegate :folio_items, to: :document

      def folio_items_by_location
        folio_items.group_by { |item| item.permanent_location.code }
      end

      def locations
        folio_items_by_location.map do |permanent_location_code, items_in_location|
          label = items_in_location.first.permanent_location&.name
          Location.new(items: display_items(items_in_location, permanent_location_code), permanent_location_code:, label:)
        end
      end

      def display_items(items_in_location, permanent_location_code)
        items_in_location.map do |item|
          Item.new(call_number: item.constructed_call_number || 'No call number',
                   barcode: item.barcode || 'No barcode',
                   location: item.effective_location&.code == permanent_location_code ? nil : item.effective_location&.name)
        end
      end

      def render?
        folio_items.present?
      end
    end
  end
end
