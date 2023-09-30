# frozen_string_literal: true

# This overrides the blacklight provided component to add the facet options checkbox group at the top.
module Articles
  module Response
    class FacetGroupComponent < Blacklight::Response::FacetGroupComponent
      def limiters
        @limiters ||= helpers.facet_options_presenter.limiters
      end
    end
  end
end
