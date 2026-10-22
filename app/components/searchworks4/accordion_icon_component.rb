# frozen_string_literal: true

module Searchworks4
  # The chevron Bootstrap 6 expects inside an accordion's <summary class="accordion-header">
  class AccordionIconComponent < ViewComponent::Base
    def call
      tag.svg(class: 'accordion-icon', xmlns: 'http://www.w3.org/2000/svg', viewBox: '0 0 16 16', fill: 'none',
              stroke: 'currentColor', 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'aria-hidden': 'true') do
        tag.path(d: 'm2 5 6 6 6-6')
      end
    end
  end
end
