# frozen_string_literal: true

module SearchResult
  module MiniBento
    class LayoutComponent < ViewComponent::Base
      renders_one :alternate_catalog_body

      def initialize(close:, alternate_url:)
        @close = close
        @alternate_url = alternate_url
        super
      end

      attr_reader :alternate_url

      def close?
        @close
      end
    end
  end
end
