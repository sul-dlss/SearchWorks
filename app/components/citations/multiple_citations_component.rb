# frozen_string_literal: true

module Citations
  class MultipleCitationsComponent < ViewComponent::Base
    attr_reader :documents

    # @param [Array<SolrDocument>] documents to generate citations for
    def initialize(documents:)
      @documents = documents
      super()
    end

    # @param [SolrDocument] the document to return citations for
    # @return [Hash] A hash of citations for the supplied document in the form of { citation_style => [citation_text] }
    def citations(document)
      citation_hash = {}

      if document.eds?
        citation_hash.merge!(document.eds_citations)
      else
        citation_hash.merge!(document.mods_citations)
      end

      citation_hash.presence || Citation::NULL_CITATION
    end
  end
end
