# frozen_string_literal: true

module Facets
  class GroupComponent < Blacklight::Response::FacetGroupComponent
    def initialize(container_classes: 'facets sidenav facets-toggleable-lg mb-md-4', show_button: false, facet_group: nil, **)
      @show_button = show_button
      @facet_group = facet_group
      super(container_classes: container_classes, **)
    end

    def collapse_toggle_button(panel_id)
      render button_component.new(panel_id: panel_id,
                                  classes: "btn btn-outline-primary col-12 facet-toggle-button d-block d-md-none")
    end
  end
end
