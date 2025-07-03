# frozen_string_literal: true

class StanfordOnlySpanComponent < ViewComponent::Base
  attr_reader :aria

  def initialize(aria: { label: 'Stanford-only' })
    super
    @aria = aria
  end

  def call
    tag.span(aria:, class: "ms-1") do
      render StanfordOnlyIconComponent.new
    end
  end
end