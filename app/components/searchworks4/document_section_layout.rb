module Searchworks4
  class DocumentSectionLayout < ViewComponent::Base
    def initialize(title:, heading_level: :h2, dl_classes: 'dl-horizontal')
      @title = title
      @heading_level = heading_level
      @dl_classes = dl_classes
      super
    end

    def render?
      content? && helpers.html_present?(content)
    end
  end
end
