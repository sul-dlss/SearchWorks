# frozen_string_literal: true

module Articles
  module Response
    class MoreFacetsListComponent < Blacklight::FacetFieldListComponent
      LIMIT = 20

      def cached_presenters
        @cached_presenters ||= facet_item_presenters
      end

      def has_more?
        cached_presenters.length > LIMIT
      end

      def facet_items(wrapping_element: :li, **item_args)
        @visible_presenters = cached_presenters.values_at(..LIMIT - 1).compact
        facet_item_component_class.with_collection(@visible_presenters, wrapping_element: wrapping_element, **item_args.merge(hidden: false))
      end

      def facet_hidden_items(wrapping_element: :li, **item_args)
        @hidden_presenters = cached_presenters.values_at(LIMIT..)

        facet_item_component_class.with_collection(@hidden_presenters, wrapping_element: wrapping_element, **item_args.merge(hidden: true))
      end

      def facet_item_component_class
        FacetItemComponent
      end
    end
  end
end
