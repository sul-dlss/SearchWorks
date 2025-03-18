# frozen_string_literal: true

module Blacklight
  module Icons
    # This is the remove (x) icon for the facets and constraints.
    # You can override the default svg by setting:
    #   Blacklight::Icons::RemoveComponent.svg = '<svg>your SVG here</svg>'
    class RemoveComponent < Blacklight::Icons::IconComponent
      def call
        tag.span class: classes + ['remove-icon'], **@options do
          '✖'
        end
      end
    end
  end
end
