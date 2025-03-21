# frozen_string_literal: true

module Searchworks
  module Icons
    # :nodoc:
    class GalleryIcon < ::ViewComponent::Base
      def call
        tag.i class: 'fa fa-th', aria: { hidden: true }
      end
    end
  end
end
