# frozen_string_literal: true

# This is a copy of the Blacklight 8 version of this component.
# We should be able to delete this local copy after we migrate to Blacklight 8
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

      def page_location
        helpers.page_location
      end
    end
  end
end
