# frozen_string_literal: true

module AccessPanels
  class GoogleBooksPreviewComponent < AccessPanels::Base
    def book_ids
      helpers.get_book_ids(document)
    end

    def render?
      book_ids.values.any?(&:present?)
    end

    def classes
      "google-books #{(book_ids['isbn'] + book_ids['oclc'] + book_ids['lccn']).join(' ')}"
    end
  end
end
