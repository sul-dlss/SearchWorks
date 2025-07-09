# frozen_string_literal: true

# Overriding the Blacklight component to move the start over button
module Searchworks4
  class ConstraintsComponent < Blacklight::ConstraintsComponent
    def initialize(start_over_component: Searchworks4::StartOverButtonComponent,
                   query_constraint_component: Searchworks4::ConstraintLayoutComponent,
                   facet_constraint_component_options: { layout: Searchworks4::ConstraintLayoutComponent },
                   **args)
      super
      @classes += ' gap-2 mt-3'
    end
  end
end
