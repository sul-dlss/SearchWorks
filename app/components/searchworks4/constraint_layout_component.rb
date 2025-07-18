# frozen_string_literal: true

module Searchworks4
  class ConstraintLayoutComponent < Blacklight::ConstraintLayoutComponent
    # This extension allows us to pass in the prefix value for advanced search constraints
    def initialize(value:, label: nil, remove_path: nil, classes: nil, prefix: nil, search_state: nil)
      super(value:, label:, remove_path:, classes:, search_state:)
      @prefix = prefix
    end

    def remove_button
      return unless @remove_path

      link_to(@remove_path, class: 'btn btn-outline-secondary remove') do
        tag.span('', class: 'bi bi-x fs-4 d-flex', aria: { hidden: true }) +
          tag.span(remove_aria_label, class: "visually-hidden")
      end
    end
  end
end
