# frozen_string_literal: true

module Searchworks4
  class ThumbnailComponent < LinkThumbnailComponent
    def call
      tag.div(class: @classes) do
        value
      end
    end
  end
end
