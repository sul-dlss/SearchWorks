# frozen_string_literal: true

module Searchworks4
  module Item
    class PublicNoteComponent < ViewComponent::Base
      attr_reader :item

      def initialize(item:)
        super()

        @item = item
      end

      delegate :public_note, to: :item

      def render?
        public_note.present?
      end

      # encourage long lines to wrap at punctuation
      # Note: the default line break character is the zero-width space
      def inject_line_break_opportunities(text, line_break_character: '​')
        text.gsub(/([:,;.]+)/, "\\1#{line_break_character}")
      end
    end
  end
end
