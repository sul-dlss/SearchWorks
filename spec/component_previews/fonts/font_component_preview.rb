# frozen_string_literal: true

class DummyComponent < ViewComponent::Base
  def initialize(string:)
    @string = string
    super()
  end

  def call
    @string
  end
end

# This is a preview for the FontComponent.
# It renders a simple message using the DummyComponent.
# The message can be customized by passing a different name.
module Fonts
  class FontComponentPreview < Lookbook::Preview
    layout 'lookbook'

    # @!group Variations

    # @label Tibetan (13885669)
    def tibetan
      render DummyComponent.new(string: "བོད་ཀྱི་གསོ་བ་རིག་པའི་ལོ་རྒྱུས་ཀྱི་བང་མཛོད་གཡུ་ཐོག་བླ་མ་དྲན་གླུ།")
    end

    # @label Cyrillic (in00000002927)
    def cyrillic
      render DummyComponent.new(string: "Strategii͡a planirovanii͡a izbiratelʹnoĭ kampanii")
    end

    # @!endgroup
  end
end
