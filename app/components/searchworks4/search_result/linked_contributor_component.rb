# frozen_string_literal: true

module Searchworks4
  module SearchResult
    # A single contributor with a search link, for rendering in search results
    class LinkedContributorComponent < ViewComponent::Base
      def initialize(linked_contributor:, marc_type: :contributors)
        @contributor = linked_contributor
        @marc_type = marc_type
        super()
      end

      attr_reader :contributor, :marc_type

      def render?
        link_text.present?
      end

      # Is there an original language version of the name?
      def vern?
        vern_link_text.present?
      end

      # The search link for this contributor
      def contributor_link
        helpers.link_to link_text, search_catalog_path(q: "\"#{search_text}\"", search_field: 'search_author')
      end

      # The search link for the original language version of the name, if any
      def vern_contributor_link
        helpers.link_to vern_link_text, search_catalog_path(q: "\"#{vern_search_text}\"", search_field: 'search_author') if vern?
      end

      private

      # Text of the search link
      def link_text
        normalize(contributor['link'].presence)
      end

      # Text of the search link in its original language, if any
      def vern_link_text
        normalize(contributor.dig('vern', 'link').presence)
      end

      # The text that will be searched when the link is clicked
      def search_text
        normalize(contributor['search'].presence) || link_text
      end

      # The text that will be searched, in its original language, if any
      def vern_search_text
        normalize(contributor.dig('vern', 'search').presence) || vern_link_text
      end

      # Text to display after the link, usually the contributor's role(s)
      # Normalized to lowercase and prefixed with a comma, e.g. ", editor"
      def post_text
        (normalize(contributor['post_text'].presence) || fallback_label).downcase.gsub(/^(\w)/, ', \1')
      end

      # Used as post_text if none was indexed for this contributor
      # Based on the names of the MARC fields for the contributor type
      def fallback_label
        helpers.t("#{marc_type}.label", scope: 'searchworks.marc_fields.linked_author')
      end

      # Strip trailing punctuation and whitespace from names and links
      def normalize(text)
        return unless text

        text.strip.gsub(/[,.]$/, '')
      end
    end
  end
end
