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

    # take the main search query out of the constraints bar
    def query_constraints
      render(@facet_constraint_component.with_collection(clause_presenters.to_a, **@facet_constraint_component_options))
    end
  end
end
