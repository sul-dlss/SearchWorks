# frozen_string_literal: true

module Searchworks4
  class OnlineAvailabilityComponent < Blacklight::Component
    attr_reader :document

    delegate :link_to_document, to: :helpers

    def initialize(document:)
      @document = document
      super()
    end

    def render?
      document.preferred_online_links.any?
    end
  end
end
