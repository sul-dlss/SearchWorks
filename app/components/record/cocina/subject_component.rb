# frozen_string_literal: true

module Record
  module Cocina
    class SubjectComponent < ViewComponent::Base
      def initialize(document:)
        super()
        @document = document
      end

      attr_reader :document

      delegate :cocina_display, to: :document

      def fields
        @fields ||= cocina_display.subject_display_data + cocina_display.genre_display_data
      end

      def render?
        fields.present?
      end

      private

      # Use the config from the CocinaDisplay object to concatenate links
      # with its configured delimiter.
      def render_values(object)
        safe_join(linked_values(object.values), object.delimiter)
      end

      # Build an array of links for the given values.
      # Each link includes all the previous values as search terms, e.g. for
      # values ["History", "United States"], the first link will search for
      # "History" and the second link will search for "History" + "United States".
      def linked_values(values)
        values.reduce([[], []]) do |results, value|
          links, terms = results
          terms.push(value)
          combined_terms = terms.map { |term| "\"#{term}\"" }.join(' ')
          links.push(link_to(value, search_catalog_path(q: combined_terms, search_field: 'subject_terms')))
          [links, terms]
        end.first
      end
    end
  end
end
