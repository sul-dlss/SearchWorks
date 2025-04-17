# frozen_string_literal: true

module Articles
  module Response
    class FacetItemComponent < Blacklight::FacetItemComponent
      def initialize(hidden:, facet_item:, wrapping_element: 'li', suppress_link: false)
        super(facet_item:, wrapping_element:, suppress_link:)
        @hidden = hidden
      end

      def call
        # if the downstream app has overridden the helper methods we'd usually call,
        # use the helpers to preserve compatibility
        content = if @selected
                    render_selected_facet_value
                  else
                    render_facet_value
                  end

        return '' if content.blank?
        return content unless @wrapping_element

        content_tag :li, content, hidden: @hidden
      end
    end
  end
end
