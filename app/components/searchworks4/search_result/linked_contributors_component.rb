# frozen_string_literal: true

module Searchworks4
  module SearchResult
    # Render the list of contributors with search links on a search result.
    # Works with MARC-based and Cocina-based documents.
    class LinkedContributorsComponent < ViewComponent::Base
      def initialize(document:)
        @document = document
        super()
      end

      attr_reader :document

      def creators
        all_contributors.fetch('creator', [])
      end

      def corporate_authors
        all_contributors.fetch('corporate_author', [])
      end

      def meeting_authors
        all_contributors.fetch('meeting', [])
      end

      def other_contributors
        all_contributors.fetch('contributors', [])
      end

      def render?
        all_contributors.any?
      end

      private

      def all_contributors
        document.fetch(:author_struct, []).first || {}
      end
    end
  end
end
