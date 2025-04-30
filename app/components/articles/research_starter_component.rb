# frozen_string_literal: true

module Articles
  class ResearchStarterComponent < Blacklight::Component
    def initialize(response:)
      @response = response
      super()
    end

    def render?
      research_starter.present?
    end

    def research_starter
      @response['research_starters']&.first
    end

    def document
      @document ||= EdsDocument.new(research_starter.to_h.merge(id: "#{research_starter['eds_database_id']}__#{research_starter['eds_accession_number']}"))
    end
  end
end
