# frozen_string_literal: true

module Searchworks4
  class ThumbnailComponent < Blacklight::Document::ThumbnailComponent
    delegate :document, to: :presenter

    def initialize(presenter:, classes: ['document-thumbnail'], render_placeholder: false, render_collection_thumbnail_from_member: false, **)
      super(presenter:, counter: nil, **)
      @classes = classes
      @render_placeholder = render_placeholder
      @render_collection_thumbnail_from_member = render_collection_thumbnail_from_member
    end

    def render_placeholder?
      @render_placeholder
    end

    def render_collection_thumbnail_from_member?
      @render_collection_thumbnail_from_member
    end

    def render?
      value.present?
    end

    def value
      @value ||= sdr_thumbnail || possible_gb_cover_image || placeholder_thumbnail
    end

    def sdr_thumbnail
      thumbnail_src = document.image_urls(:large)&.first
      thumbnail_src ||= document.collection_members.first&.image_urls(:large)&.first if document.is_a_collection? && render_collection_thumbnail_from_member?

      image_tag(thumbnail_src, class: 'stacks-image', alt: '') if thumbnail_src.present?
    end

    def possible_gb_cover_image
      book_ids = helpers.get_book_ids(document)

      css_class = (book_ids['isbn'] + book_ids['oclc'] + book_ids['lccn']).join(' ')
      isbn = book_ids['isbn'].join(',')
      oclc = book_ids['oclc'].join(',')
      lccn = book_ids['lccn'].join(',')

      if css_class.present?
        img = tag.img class: "cover-image center-block #{css_class}",
                      hidden: true,
                      alt: '',
                      data: {
                        google_cover_image_target: 'image',
                        isbn: isbn,
                        oclc: oclc,
                        lccn: lccn
                      }
      end

      safe_join([img, placeholder_thumbnail].compact)
    end

    def placeholder_thumbnail
      render Searchworks4::PlaceholderThumbnailComponent.new if render_placeholder?
    end
  end
end
