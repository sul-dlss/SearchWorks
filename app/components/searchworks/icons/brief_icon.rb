# frozen_string_literal: true

module Searchworks
  module Icons
    class BriefIcon < ::ViewComponent::Base
      # :nodoc:
      def call
        tag.i class: 'fa fa-align-justify', aria: { hidden: true }
      end
    end
  end
end
