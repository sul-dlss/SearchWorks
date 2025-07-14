# frozen_string_literal: true

module Masthead
  class LayoutComponent < ViewComponent::Base
    renders_one :header
    renders_one :search
    renders_one :aside

    attr_reader :classes

    def initialize(classes: [])
      super

      @classes = Array(classes)
    end
  end
end
