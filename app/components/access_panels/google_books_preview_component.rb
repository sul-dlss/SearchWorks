# frozen_string_literal: true

module AccessPanels
  class GoogleBooksPreviewComponent < AccessPanels::Base
    delegate :book_ids, to: :document

    def render?
      book_ids.values.any?(&:present?)
    end

    def classes
      "google-books #{(book_ids['isbn'] + book_ids['oclc'] + book_ids['lccn']).join(' ')}"
    end
  end
end
