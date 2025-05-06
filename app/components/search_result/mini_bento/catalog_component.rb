# frozen_string_literal: true

module SearchResult
  module MiniBento
    class CatalogComponent < ViewComponent::Base
      def initialize(close:)
        @close = close
        super
      end

      attr_reader :close

      def articles_url
        articles_path(q: params.fetch(:q), f: { eds_search_limiters_facet: ['Direct access to full text'] })
      end
    end
  end
end
