# frozen_string_literal: true

class FacetFieldPaginationComponent < Blacklight::FacetFieldPaginationComponent
  def initialize(facet_field:, button_classes: %w[btn btn-outline-primary])
    super
  end
end
