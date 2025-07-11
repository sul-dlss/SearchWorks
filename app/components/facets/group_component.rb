# frozen_string_literal: true

module Facets
  class GroupComponent < Blacklight::Response::FacetGroupComponent
    def initialize(show_button: false, facet_group: nil, **)
      @show_button = show_button
      @facet_group = facet_group
      super(**)
    end
  end
end
