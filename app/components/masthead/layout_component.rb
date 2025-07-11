# frozen_string_literal: true

module Masthead
  class LayoutComponent < ViewComponent::Base
    renders_one :header
    renders_one :search
    renders_one :aside
    renders_one :back_link

    attr_reader :classes

    def initialize(classes: [])
      super

      @classes = Array(classes)
    end

    def back_icon
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-forward-fill ps-1" viewBox="0 0 16 16" style="transform: rotate(180deg);">
        <path d="m9.77 12.11 4.012-2.953a.647.647 0 0 0 0-1.114L9.771 5.09a.644.644 0 0 0-.971.557V6.65H2v3.9h6.8v1.003c0 .505.545.808.97.557"/>
      </svg>'.html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
