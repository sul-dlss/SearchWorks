# frozen_string_literal: true

module Searchworks4
  module Response
    class FacetGroupComponent < Blacklight::Response::FacetGroupComponent
      def initialize(**kwargs)
        super
        @body_classes = body_classes.gsub('d-lg-block', "d-#{mobile_size}-block")
      end

      def collapse_toggle_button(panel_id)
        render button_component.new(panel_id: panel_id, classes: "btn btn-outline-primary col-12 facet-toggle-button d-block d-#{mobile_size}-none")
      end

      def mobile_size
        "md"
      end
    end
  end
end
