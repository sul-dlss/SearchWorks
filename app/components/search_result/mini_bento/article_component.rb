# frozen_string_literal: true

module SearchResult
  module MiniBento
    class ArticleComponent < ViewComponent::Base
      def initialize(drawer: true)
        @drawer = drawer
        super()
      end

      attr_reader :drawer

      def render?
        params[:q].present?
      end

      def call
        render LayoutComponent.new(drawer:, i18n_key: :article, url:)
      end

      def url
        search_catalog_path(q: params.fetch(:q))
      end
    end
  end
end
