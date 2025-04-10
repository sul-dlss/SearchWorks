# frozen_string_literal: true

###
# Returns a MODS citation formatted for use by SearchWorks
module Citations
  class MarcCitation
    attr_reader :citeproc_item

    # Names of CSL files in https://github.com/citation-style-language/styles
    FORMATS = %w[apa chicago-author-date harvard-cite-them-right modern-language-association
                 turabian-author-date].freeze

    # @param citeproc_item [CiteProc::Item]
    def initialize(citeproc_item:)
      @citeproc_item = citeproc_item
    end

    # @return [Hash] A hash with the preferred citation style as key and citation text as value
    def all_citations
      FORMATS.each_with_object({}) do |style, obj|
        label = style
        label = 'marc_apa' if label == 'apa'
        obj[label] = citation(style:).html_safe # rubocop:disable Rails/OutputSafety
      end
    end

    private

    def citation(style: 'apa')
      cp = CiteProc::Processor.new style:, format: 'html'
      cp.import citeproc_item
      cp.render(:bibliography, id: citeproc_item.id).first
    end
  end
end
