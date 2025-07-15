# frozen_string_literal: true

module Searchworks
  module Icons
    # :nodoc:
    class GalleryIcon < ::ViewComponent::Base
      def call
        tag.i class: 'bi bi-grid-3x2-gap-fill', aria: { hidden: true }
      end
    end
  end
end
