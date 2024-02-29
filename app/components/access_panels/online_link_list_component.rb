# frozen_string_literal: true

module AccessPanels
  class OnlineLinkListComponent < ViewComponent::Base
    def initialize(document:, links:)
      @document = document
      @links = links
      super()
    end

    attr_accessor :document, :links
  end
end
