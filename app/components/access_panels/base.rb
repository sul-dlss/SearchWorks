# frozen_string_literal: true

module AccessPanels
  class Base < ViewComponent::Base
    attr_reader :document

    def initialize(document:, layout: AccessPanels::LayoutComponent)
      @document = document
      @layout = layout
    end
  end
end
