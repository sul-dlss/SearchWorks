# frozen_string_literal: true

module ThumbnailHelper
  def render_cover_image(document, options = {})
    book_ids = get_book_ids(document)

    locals = {
      document:,
      css_class: (book_ids['isbn'] + book_ids['oclc'] + book_ids['lccn']).join(' '),
      isbn: book_ids['isbn'].join(','),
      oclc: book_ids['oclc'].join(','),
      lccn: book_ids['lccn'].join(',')
    }

    begin
      render(partial: "catalog/thumbnails/#{document.display_type}_thumbnail", locals:)
    rescue ActionView::MissingTemplate
      nil
    end
  end
end
