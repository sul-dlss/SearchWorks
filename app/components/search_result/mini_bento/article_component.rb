# frozen_string_literal: true

module SearchResult
  module MiniBento
    class ArticleComponent < ViewComponent::Base
      def initialize(offcanvas: true)
        @offcanvas = offcanvas
        super
      end

      attr_reader :offcanvas

      def render?
        params[:q].present?
      end

      def call
        render LayoutComponent.new(offcanvas:, i18n_key: :article, url:)
      end

      def url
        search_catalog_path(q: params.fetch(:q))
      end
    end
  end
end
