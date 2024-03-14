# frozen_string_literal: true

module AccessPanels
  class GoogleBooksPreviewComponent < AccessPanels::Base
    def initialize(document:, link_text: 'Limited preview', **html_attrs)
      super(document:)

      @link_text = link_text
      @html_attrs = html_attrs
    end

    def book_ids
      helpers.get_book_ids(document)
    end

    def render?
      book_ids.values.any?(&:present?)
    end
  end
end
