# frozen_string_literal: true

module Masthead
  class LayoutComponent < ViewComponent::Base
    renders_one :header
    renders_one :search
    renders_one :aside

    attr_reader :label, :classes

    def initialize(label: 'Masthead', classes: [])
      super()

      @label = label
      @classes = Array(classes)
    end
  end
end
