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
      document.preferred_online_links.any? || (document.druid.present? && (!document.mods? || document.published_content?))
    end

    def links
      document.preferred_online_links.presence || [sdr_link]
    end

    def sdr_link
      return unless document.druid

      Links::Link.new({ href: helpers.url_for(document), link_text: 'See record', stanford_only: false })
    end
  end
end
