# frozen_string_literal: true

module Searchworks4
  class PlaceholderThumbnailComponent < ViewComponent::Base
    def call
      tag.span class: 'fake-cover', aria: { hidden: true } do
        tag.div 'Book cover not available', class: 'text-center fake-cover-text'
      end
    end
  end
end
