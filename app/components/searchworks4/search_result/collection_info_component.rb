# frozen_string_literal: true

module Searchworks4
  module SearchResult
    class CollectionInfoComponent < ViewComponent::Base
      def initialize(collection:)
        @collection = collection
        super
      end

      attr_reader :collection

      def render?
        helpers.page_location.collection? && collection.present?
      end
    end
  end
end
