# frozen_string_literal: true

module Searchworks4
  module SearchResult
    class ItemMenuComponent < ViewComponent::Base
      def initialize(document:)
        @document = document
        super
      end

      attr_reader :document

      def cite_path
        "/documents/#{document.id}/cite"
      end

      def email_path
        "/documents/#{document.id}/email"
      end

      def copy_url
        solr_document_url(document)
      end
    end
  end
end
