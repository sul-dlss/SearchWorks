# frozen_string_literal: true

###
# Returns a Cocina citation formatted for use by SearchWorks
module Citations
  class CocinaCitation
    CITATION_STYLE = 'preferred'

    attr_reader :citation

    # @param cocina_display [CocinaDisplay::Record] the cocina display record
    def initialize(cocina_display:)
      @citation = cocina_display.preferred_citation
    end

    # @return [Hash] A hash with the preferred citation style as key and citation text as value
    def all_citations
      return { CITATION_STYLE => citation } if citation.present?

      {}
    end
  end
end
