# frozen_string_literal: true

class StanfordOnlyPopoverComponent < ViewComponent::Base
  def call
    tag.button(class: 'stanford-only btn',
               data: { 'bs-toggle': 'popover', 'bs-placement': 'right', 'bs-content': 'Available to Stanford-affiliated users only. Log in to access.' },
               aria: { label: 'Stanford-only' }) do
      render StanfordOnlyIconComponent.new
    end
  end
end
