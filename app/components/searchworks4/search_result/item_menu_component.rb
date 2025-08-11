# frozen_string_literal: true

module Searchworks4
  module SearchResult
    class ItemMenuComponent < ViewComponent::Base
      def initialize(document:)
        @document = document
        super()
      end

      attr_reader :document

      def cite_path
        document.eds? ? citation_article_path(document) : citation_solr_document_path(document)
      end

      def email_path
        document.eds? ? email_article_path(document) : email_solr_document_path(document)
      end

      def copy_url
        document.eds? ? eds_document_url(document) : solr_document_url(document)
      end
    end
  end
end
