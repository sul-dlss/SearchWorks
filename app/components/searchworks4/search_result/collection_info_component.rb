# frozen_string_literal: true

module Searchworks4
  module SearchResult
    class CollectionInfoComponent < ViewComponent::Base
      def initialize(collection:)
        @collection = collection
        super()
      end

      attr_reader :collection

      def render?
        collection.present?
      end

      def presenter
        @presenter ||= helpers.document_presenter(collection)
      end

      def resource_icon
        helpers.render_resource_icon(presenter.formats)
      end
    end
  end
end
