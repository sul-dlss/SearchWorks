# frozen_string_literal: true

module AccessPanels
  class OnlineLinkListComponent < ViewComponent::Base
    def initialize(document:, links:)
      @document = document
      @links = links
      super()
    end

    def sfx_links
      return [] if document.marc_links.sfx.blank?

      document.marc_links.sfx
    end

    attr_accessor :document, :links
  end
end
