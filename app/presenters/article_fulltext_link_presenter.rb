# frozen_string_literal: true

##
# A presenter class handle the logic to render markup for fulltext links from EDS
class ArticleFulltextLinkPresenter
  delegate :eds_document_url, :article_fulltext_link_url, :link_to, :image_tag, :image_url, :render, to: :@context
  def initialize(document:, context:)
    @document = document
    @context = context
  end

  def links
    if document.preferred_online_links.any?
      document.preferred_online_links.map { |link| render_fulltext_link(link) }
    elsif document_has_fulltext?
      ["#{online_label} #{link_to('View on detail page', eds_document_url(document))}"]
    else
      []
    end
  end

  private

  attr_reader :document

  def online_label
    '<span class="fw-semibold available-online">Available online <i class="bi bi-forward-fill"></i></span>'.html_safe
  end

  def stanford_only_icon
    render StanfordOnlyPopoverComponent.new
  end

  def document_has_fulltext?
    document.html_fulltext?
  end

  def render_fulltext_link(link)
    if link.href == 'detail' # PDFs
      detail_link_markup(link)
    else
      "#{online_label} #{link_to(link.text, link.href)}"
    end
  end

  def detail_link_markup(link)
    <<-HTML
      #{online_label}
      #{(link_to('View on detail page', eds_document_url(document)) if document_has_fulltext?)}
      #{image_tag(image_url('pdf-icon.svg'), height: '20px', alt: 'PDF') unless link.type == 'other'}
      #{link_to(link.text, article_fulltext_link_url(id: document.id, type: link.type), data: { turbo: false })}
      #{stanford_only_icon}
    HTML
  end
end
