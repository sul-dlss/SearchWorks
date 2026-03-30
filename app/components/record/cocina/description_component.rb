# frozen_string_literal: true

module Record
  module Cocina
    class DescriptionComponent < ViewComponent::Base
      def initialize(document:)
        super()
        @document = document
      end

      attr_reader :document

      delegate :cocina_display, to: :document

      COMMA = ', '
      SEMICOLON = '; '

      # Ordered list of fields and delimiters to display
      def field_map
        @field_map ||= [
          [cocina_display.title_display_data(exclude_primary: true), COMMA],
          [cocina_display.form_display_data, SEMICOLON],
          [cocina_display.form_note_display_data, COMMA],
          [cocina_display.event_display_data, SEMICOLON],
          [cocina_display.event_note_display_data, COMMA],
          [cocina_display.language_display_data, SEMICOLON],
          [cocina_display.map_display_data, COMMA]
        ].select { |field, _| field.present? }
      end

      def render?
        field_map.present?
      end
    end
  end
end
