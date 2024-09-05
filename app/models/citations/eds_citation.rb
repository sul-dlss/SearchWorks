# frozen_string_literal: true

###
# Returns an EDS citation formatted for use by SearchWorks
module Citations
  class EdsCitation
    CITATION_STYLES = %w[apa chicago harvard mla turabian].freeze

    attr_reader :eds_citations

    # @param eds_citations [Array<Hash>] An array of EDS citations
    def initialize(eds_citations:)
      @eds_citations = eds_citations
    end

    # @return [Hash] A hash with citation styles as keys and citation text as values.
    def all_citations
      matching_styles.index_with do |id|
        eds_citations.select { |style| style.fetch('id', nil) == id }.pick('data')&.html_safe # rubocop:disable Rails/OutputSafety
      end.compact
    end

    private

    def matching_styles
      eds_citations.pluck('id').select { |id| CITATION_STYLES.include?(id) }
    end
  end
end
