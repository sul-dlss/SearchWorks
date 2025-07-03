# frozen_string_literal: true

module AccessPanels
  class LayoutComponent < ViewComponent::Base
    renders_one :header
    renders_one :title, lambda { |classes: [], tag: 'h3', &block|
      content_tag tag, class: classes, &block
    }
    renders_one :body
    renders_one :after

    def initialize(classes: [], **html_attrs)
      @html_attrs = html_attrs
      @classes = %w[mb-4 access-panel] + Array(classes)
    end
  end
end
