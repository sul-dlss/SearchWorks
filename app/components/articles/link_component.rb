# frozen_string_literal: true

module Articles
  class LinkComponent < Searchworks4::LinkComponent
    attr_reader :document, :link

    def initialize(link: nil, document: nil)
      super(link: link)

      @document = document
    end

    def render?
      link.present? || document.html_fulltext?
    end

    def icon
      return unless link

      image_tag(image_url('pdf-icon.svg'), height: '20px', alt: 'PDF') unless link.type == 'other'
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

    def casalini_text = nil
    def additional_text = nil
  end
end
