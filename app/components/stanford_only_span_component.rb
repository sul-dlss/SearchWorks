# frozen_string_literal: true

class StanfordOnlySpanComponent < ViewComponent::Base
  def call
    tag.span(aria: { label: 'Stanford-only' }, class: "ms-1") do
      render StanfordOnlyIconComponent.new
    end
  end
end
