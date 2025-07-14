# frozen_string_literal: true

module Searchworks4
  module SearchResult
    class CollectionFindingAidLinkComponent < Searchworks4::AccessLinkComponent
      def initialize(finding_aid:)
        @finding_aid = finding_aid
        super(link: finding_aid.first)
      end

      def render?
        @link.present?
      end
    end
  end
end
