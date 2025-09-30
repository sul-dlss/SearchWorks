# frozen_string_literal: true

module Articles
  class LinkComponent < Searchworks4::LinkComponent
    def render?
      link.present? || document.html_fulltext?
    end

    def icon
      return unless link && %w[ebook-pdf pdflink pdf].include?(link.type)

      pdf_icon
    end

    def pdf_icon
      sanitize "<i class='bi bi-filetype-pdf link-icon' aria-label='PDF'></i>"
    end

    def href
      if link.nil?
        eds_document_url(document) if document.html_fulltext?
      elsif link.href == 'detail'
        article_fulltext_link_url(id: document.id, type: link.type)
      else
        super
      end
    end

    def stanford_only?
      return true if link.nil? && document.html_fulltext?
      return true if link.href == 'detail'

      super
    end

    def link_text
      return 'View on detail page' if link.nil?

      super
    end

    def link_attr
      { data: { turbo: false } }
    end

    def link_text_for_display
      icon.present? ? (sanitize "#{icon} #{link_text}") : link_text
    end

    def casalini_text = nil
    def additional_text = nil
  end
end
