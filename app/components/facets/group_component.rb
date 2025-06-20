# frozen_string_literal: true

module Facets
  class GroupComponent < Blacklight::Response::FacetGroupComponent
    # TODO: Remove this method after upgrading to Blacklight 9.0.0.beta2
    def body_classes
      'facets-collapse d-lg-block collapse accordion'
    end
  end
end
