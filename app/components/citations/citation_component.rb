# frozen_string_literal: true

module Citations
  class CitationComponent < ViewComponent::Base
    attr_reader :citations

    def initialize(citations:)
      @citations = citations
      super()
    end

    def render?
      citations.present?
    end
  end
end
