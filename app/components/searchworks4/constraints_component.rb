# frozen_string_literal: true

# Overriding the Blacklight component to move the start over button
module Searchworks4
  class ConstraintsComponent < Blacklight::ConstraintsComponent
    def initialize(**args)
      super
      @start_over_component = Searchworks4::StartOverButtonComponent
    end
  end
end
