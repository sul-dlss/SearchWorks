# frozen_string_literal: true

module Searchworks4
  class ConstraintLayoutComponent < Blacklight::ConstraintLayoutComponent
    def remove_button
      return unless @remove_path

      link_to(@remove_path, class: 'btn btn-outline-secondary remove') do
        tag.span('', class: 'bi bi-x', aria_hidden: true) +
          tag.span(remove_aria_label, class: "visually-hidden")
      end
    end
  end
end
