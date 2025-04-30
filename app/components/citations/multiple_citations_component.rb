# frozen_string_literal: true

module Citations
  class MultipleCitationsComponent < ViewComponent::Base
    attr_reader :documents, :oclc_citations

    # @param [Array<SolrDocument>] documents to generate citations for
    # @param [Hash] oclc_citations in the form of { oclc_number => { citation_style => citation_text } }
    #               for lookup of pre-fetched OCLC citations
    def initialize(documents:, oclc_citations:)
      @documents = documents
      @oclc_citations = oclc_citations
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
        citation_hash.merge!(oclc_citation(document))
      end

      citation_hash.presence || Citation::NULL_CITATION
    end

    private

    def oclc_citation(document)
      return {} if document.oclc_number.blank?

      oclc_citations.fetch(document.oclc_number, {})
    end
  end
end
