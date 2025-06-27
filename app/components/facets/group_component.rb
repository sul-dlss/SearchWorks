# frozen_string_literal: true

module Facets
  class GroupComponent < Blacklight::Response::FacetGroupComponent
    def collapse_toggle_button(panel_id, classes:)
      render button_component.new(panel_id:, classes:)
    end
  end
end
