# frozen_string_literal: true

###
# Returns a MODS citation formatted for use by SearchWorks
module Citations
  class MarcCitation
    CITATION_STYLE = 'marc_apa'

    attr_reader :citeproc_item

    # @param citeproc_item [CiteProc::Item]
    def initialize(citeproc_item:)
      @citeproc_item = citeproc_item
    end

    # @return [Hash] A hash with the preferred citation style as key and citation text as value
    def all_citations
      { CITATION_STYLE => citation.html_safe } # rubocop:disable Rails/OutputSafety
    end

    private

    def citation(style: 'apa')
      cp = CiteProc::Processor.new style:, format: 'html'
      cp.import citeproc_item
      cp.render(:bibliography, id: citeproc_item.id).first
    end
  end
end
