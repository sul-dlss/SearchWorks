module AccessPanels
  class LayoutComponent < ViewComponent::Base
    renders_one :header
    renders_one :title
    renders_one :body
    renders_one :after

    def initialize(classes: [], **html_attrs)
      @html_attrs = html_attrs
      @classes = Array(classes)
    end
  end
end
