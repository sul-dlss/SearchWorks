# frozen_string_literal: true

module Citations
  class MultipleCitationsComponent < ViewComponent::Base
    attr_reader :documents

    # @param [Array<SolrDocument>] documents to generate citations for
    def initialize(documents:)
      @documents = documents
      super()
    end

    delegate :refworks_export_url, :search_state, :bookmarks_export_url, to: :helpers

    def all_citations
      @all_citations ||= @documents.map { |doc| citations(doc) }
    end

    # @param [SolrDocument] the document to return citations for
    # @return [Hash] A hash of citations for the supplied document in the form of { citation_style => [citation_text] }
    def citations(document)
      return document.citations unless document.eds?

      document.eds_citations.presence || Citation::NULL_CITATION
    end
  end
end
