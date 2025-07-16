# frozen_string_literal: true

module Searchworks
  module Icons
    class ListIcon < ::ViewComponent::Base
      # :nodoc:
      def call
        tag.i class: 'fa fa-th-list', aria: { hidden: true }
      end
    end
  end
end
