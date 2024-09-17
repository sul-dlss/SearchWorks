# frozen_string_literal: true

###
# Returns a MODS citation formatted for use by SearchWorks
module Citations
  class ModsCitation
    CITATION_STYLE = 'preferred'

    attr_reader :notes

    # @param notes [Array<Hash>] An array of MODS notes that may contain a citation
    def initialize(notes:)
      @notes = notes
    end

    # @return [Hash] A hash with the preferred citation style as key and citation text as value
    def all_citations
      return { CITATION_STYLE => "<p>#{mods_citation}</p>".html_safe } if mods_citation.present? # rubocop:disable Rails/OutputSafety

      {}
    end

    private

    def mods_citation
      notes.find { |note| note.label.downcase.match?(/preferred citation:?/) }&.values&.join
    end
  end
end
