# frozen_string_literal: true

module SearchResult
  module MiniBento
    class ArticleComponent < ViewComponent::Base
      def initialize(close:)
        @close = close
        super
      end

      attr_reader :close

      def render?
        params[:q].present?
      end

      def call
        render LayoutComponent.new(close:, i18n_key: :article, url:)
      end

      def url
        search_catalog_path(q: params.fetch(:q))
      end
    end
  end
end
