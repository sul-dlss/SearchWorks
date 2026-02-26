# frozen_string_literal: true

module Record
  module Cocina
    class FieldComponent < ViewComponent::Base
      def initialize(field:, delimiter: nil)
        super()
        @field = field
        @delimiter = delimiter
      end
      attr_reader :field, :delimiter

      # Strip trailing colons from labels for display (this was also used in MODS)
      def label
        field.label&.sub(/:$/, '')
      end

      # If a delimiter is provided, we join with that. Otherwise we wrap each value in its own dd tag
      def values
        delimiter ? [safe_join(formatted_values, delimiter)] : formatted_values
      end

      private

      # Strip blanks and auto-link any URLs
      def formatted_values
        @formatted_values ||= @field.values.compact_blank.map { |value| auto_link value }
      end
    end
  end
end
