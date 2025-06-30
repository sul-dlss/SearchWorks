# frozen_string_literal: true

module Searchworks4
  class AvailabilityComponent < Blacklight::Component
    attr_reader :document

    def initialize(document:)
      @document = document
      super()
    end

    def render?
      document.holdings.present? || document.preferred_online_links.any?
    end

    def truncated_display?
      document.holdings.items.count > 20
    end
  end
end
