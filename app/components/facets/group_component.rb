# frozen_string_literal: true

module Facets
  class GroupComponent < Blacklight::Response::FacetGroupComponent
    def initialize(container_classes: 'facets sidenav facets-toggleable-lg mb-md-4', **)
      super
    end

    def collapse_toggle_button(panel_id, classes: "btn btn-outline-primary col-12 facet-toggle-button d-block d-md-none")
      render button_component.new(panel_id:, classes:)
    end
  end
end
