# frozen_string_literal: true

module Searchworks4
  class GalleryCardPreviewButtonComponent < ViewComponent::Base
    def initialize(document_id:)
      @document_id = document_id
      super()
    end

    attr_reader :document_id
  end
end
