# frozen_string_literal: true

module Record
  class DocumentLayoutComponent < ViewComponent::Base
    renders_one :title
    renders_one :thumbnail
    renders_one :header
    renders_one :embed
    renders_one :metadata
    renders_one :footer

    attr_reader :document

    def initialize(document:)
      super()

      @document = document
    end
  end
end
