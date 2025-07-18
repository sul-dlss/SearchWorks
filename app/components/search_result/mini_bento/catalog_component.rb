# frozen_string_literal: true

module SearchResult
  module MiniBento
    class CatalogComponent < ViewComponent::Base
      def initialize(offcanvas: true)
        @offcanvas = offcanvas
        super
      end

      attr_reader :offcanvas

      delegate :current_view, to: :helpers

      def render?
        params.fetch(:q, nil).present? && current_view != 'gallery'
      end

      def call
        render LayoutComponent.new(offcanvas:, i18n_key: :catalog, url:)
      end

      def url
        articles_path(q: params.fetch(:q), f: { eds_search_limiters_facet: ['Direct access to full text'] })
      end
    end
  end
end
