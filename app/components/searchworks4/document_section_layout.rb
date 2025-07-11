# frozen_string_literal: true

module Searchworks4
  class DocumentSectionLayout < ViewComponent::Base
    def initialize(title:, classes: ['mb-5'], heading_level: :h2, dl_classes: 'dl-horizontal')
      @title = title
      @classes = classes
      @heading_level = heading_level
      @dl_classes = dl_classes
      super
    end

    def render?
      helpers.html_present?(content)
    end
  end
end
