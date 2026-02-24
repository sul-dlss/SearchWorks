# frozen_string_literal: true

module Record
  module Cocina
    class BibliographicComponent < ViewComponent::Base
      def initialize(document:)
        super()
        @document = document
      end

      attr_reader :document

      delegate :cocina_display, to: :document

      COMMA = ', '

      # Ordered list of fields and delimiters to display
      def field_map
        @field_map ||= [
          [cocina_display.general_note_display_data, nil],
          [cocina_display.related_resource_display_data, nil],
          [cocina_display.identifier_display_data, COMMA],
          [access_display_data, nil]
        ].select { |field, _| field.present? }
      end

      def render?
        field_map.present?
      end

      private

      # If the document has a druid, we don't want to show the purl for the object on the page twice.
      # The purl will show up in the OtherListingsComponent if there is a druid
      # this removes any locations that match https://purl.stanford.edu/druid
      def access_display_data
        cocina_display.access_display_data.reject do |location|
          location.values.detect do |loc|
            document.druid && /#{Settings.PURL_EMBED_RESOURCE}#{document.druid}/.match?(loc)
          end
        end
      end
    end
  end
end
