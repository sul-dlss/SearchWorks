# frozen_string_literal: true

# This is a copy of the Blacklight 9 version of this component.
module Searchworks
  module Response
    # Render a group of facet fields
    class FacetGroupComponent < Blacklight::Response::FacetGroupComponent
      def before_render
        super

        @title = t("blacklight.search.facets.access_point.#{page_location.access_point}.title",
                   access_point: page_location.access_point,
                   default: :'blacklight.search.facets.title')
      end

      private

      def collapse_toggle_button(panel_id)
        'dood'
        # render button_component.new(panel_id: panel_id, classes: 'btn btn-outline-primary facet-toggle-button d-block d-lg-none')
      end

      def page_location
        helpers.page_location
      end
    end
  end
end
