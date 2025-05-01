# frozen_string_literal: true

module SearchResult
  module MiniBento
    class ArticleComponent < ViewComponent::Base
      def initialize(close:)
        @close = close
        super
      end

      def close?
        @close
      end
    end
  end
end
