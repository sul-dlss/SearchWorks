# frozen_string_literal: true

module SearchResult
  module MiniBento
    class CatalogComponent < ViewComponent::Base
      def initialize(close:)
        @close = close
        super
      end

      attr_reader :close

      def render?
        params.fetch(:q, nil).present?
      end

      def call
        render LayoutComponent.new(close:, i18n_key: :catalog, url:)
      end

      def url
        articles_path(q: params.fetch(:q), f: { eds_search_limiters_facet: ['Direct access to full text'] })
      end
    end
  end
end
