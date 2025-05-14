# frozen_string_literal: true

module SearchResult
  module MiniBento
    class LayoutComponent < ViewComponent::Base
      def initialize(close:, url:, i18n_key:)
        @close = close
        @url = url
        @i18n_key = i18n_key
        super
      end

      attr_reader :url, :i18n_key

      def close?
        @close
      end

      def bento_url
        "https://library.stanford.edu/all?q=#{params[:q]}"
      end

      def archive_search_url
        "https://archives.stanford.edu/catalog?group=true&q=#{params[:q]}"
      end

      def exhibits_search_url
        "https://exhibits.stanford.edu/search?q=#{params[:q]}"
      end

      def geo_search_url
        "https://earthworks.stanford.edu/?q=#{params[:q]}"
      end

      def name
        t(:name, scope: i18n_scope)
      end

      def description
        t(:description, scope: i18n_scope)
      end

      def result_singular
        t(:result_singular, scope: i18n_scope)
      end

      def i18n_scope
        "searchworks.mini_bento.#{i18n_key}"
      end
    end
  end
end
