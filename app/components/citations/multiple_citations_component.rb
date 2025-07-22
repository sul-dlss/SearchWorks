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

    def citation_for_format(citations_for_document, format)
      return preferred_citation(citations_for_document) if preferred_citation_only?(citations_for_document)

      citations_for_document[format == 'apa' ? 'marc_apa' : format]
    end

    def preferred_citation_only?(citations_for_document)
      citations_for_document.one? && citations_for_document.keys.first == preferred_key
    end

    def preferred_citation(citations_for_document)
      citations_for_document[preferred_key]
    end

    def preferred_or_unavailable_citations_only?
      @preferred_or_unavailable_citations_only ||= all_citations.all? do |citations_for_document|
        preferred_citation_only?(citations_for_document) || citations_for_document == Citation::NULL_CITATION
      end
    end

    def preferred_key
      'preferred'
    end

    def unavailable_citation_count(format)
      all_citations.count do |citations|
        citation = citation_for_format(citations, format)
        citation.blank? || citation == Citation::NULL_CITATION
      end
    end
  end
end
