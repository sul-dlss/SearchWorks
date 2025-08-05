# frozen_string_literal: true

module ThumbnailHelper
  def render_cover_image(document, options = {})
    if document.is_a_collection?
      render partial: 'catalog/thumbnails/collection_thumbnail', locals: { document: document }
    else
      book_ids = get_book_ids(document)

      locals = {
        document:,
        css_class: (book_ids['isbn'] + book_ids['oclc'] + book_ids['lccn']).join(' '),
        isbn: book_ids['isbn'].join(','),
        oclc: book_ids['oclc'].join(','),
        lccn: book_ids['lccn'].join(',')
      }

      render partial: "catalog/thumbnails/item_thumbnail", locals:
    end
  end
end
