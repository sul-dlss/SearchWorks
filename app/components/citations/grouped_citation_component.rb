# frozen_string_literal: true

module Citations
  class GroupedCitationComponent < ViewComponent::Base
    attr_reader :citations

    PREFERRED_CITATION_KEY = 'preferred'

    # @param [Array<Hash>] citations in the form of [{ citation_style => citation_text }]
    def initialize(citations:)
      @citations = citations
      super()
    end

    # @return [Hash] A hash of citations grouped by style in the form of { citation_style => [citation_text] }
    def grouped_citations
      citation_styles.index_with { |style| citations.pluck(style).compact }
    end

    def render?
      citations.present?
    end

    private

    def citation_styles
      keys = citations.map(&:keys).flatten.uniq
      # It doesn't make sense to display the NULL citation
      # when grouping citations by style so remove it from the list
      keys.delete('NULL')

      # If the preferred citation is present, move it to the front of the list
      # so that it always displays first
      return keys unless keys.include?(PREFERRED_CITATION_KEY)

      keys.delete(PREFERRED_CITATION_KEY)
      keys.unshift(PREFERRED_CITATION_KEY)
    end
  end
end
