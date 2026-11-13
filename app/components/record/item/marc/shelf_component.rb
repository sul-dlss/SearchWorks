# frozen_string_literal: true

module Record
  module Item
    module Marc
      # A row of gallery cards for the documents shelved near a call number
      class ShelfComponent < ViewComponent::Base
        # @param documents [Array<SolrDocument>] the documents on the shelf, in shelf order
        # @param starting_document [SolrDocument] the document browsing started from; its card is highlighted
        # @param preview_id [String] the id of the element that shows a card's preview
        def initialize(documents:, starting_document:, preview_id:)
          @documents = documents
          @starting_document = starting_document
          @preview_id = preview_id
          super()
        end

        attr_reader :documents, :starting_document, :preview_id

        def render?
          documents.present?
        end

        def presenters
          documents.map { |document| helpers.document_presenter(document) }
        end

        def document_component
          helpers.blacklight_config.view_config(:gallery).document_component
        end
      end
    end
  end
end
