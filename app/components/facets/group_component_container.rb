# frozen_string_literal: true

module Facets
  class GroupComponentContainer < ViewComponent::Base
    def initialize(response:, offcanvas: false)
      @response = response
      @offcanvas = offcanvas
      super
    end

    def offcanvas?
      @offcanvas
    end

    def container_classes_for(group)
      classes = ["facets", "#{group}-filters"]
      # When in the offcanvas area, the facets are not toggleable
      # TODO: delete facets-toggleable-lg ?
      classes += %w[mb-md-4 sidenav facets-toggleable-lg] unless offcanvas?
      classes.join(' ')
    end

    def header_classes
      'facets-heading'
    end

    def body_classes
      @offcanvas ? 'facets-collapse accordion' : 'facets-collapse d-md-block collapse accordion'
    end
  end
end
