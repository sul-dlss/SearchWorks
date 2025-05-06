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
