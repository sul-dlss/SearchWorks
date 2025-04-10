# frozen_string_literal: true

class StanfordOnlyPopoverComponent < ViewComponent::Base
  def call
    tag.button(class: 'stanford-only btn btn-link p-0 align-baseline', style: 'height: 24px; width: 24px',
               data: { turbo: false, toggle: 'popover', placement: 'right', content: 'Available to Stanford-affiliated users only. Log in to access.' },
               aria: { label: 'Stanford-only' }) do
      render StanfordOnlyIconComponent.new
    end
  end
end
