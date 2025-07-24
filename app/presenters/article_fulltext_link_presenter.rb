# frozen_string_literal: true

##
# A presenter class handle the logic to render markup for fulltext links from EDS
class ArticleFulltextLinkPresenter
  delegate :eds_document_url, :article_fulltext_link_url, :link_to, :image_tag, :image_url, to: :context
  def initialize(document:, context:)
    @document = document
    @context = context
  end

  def links
    return [] unless online_access_panel? || document_has_fulltext?
    return access_panel_links.map { |link| render_fulltext_link(link) } if online_access_panel?

    ["#{online_label} #{link_to('View on detail page', eds_document_url(document))}"]
  end

  private

  attr_reader :document, :context

  delegate :request, to: :context
  delegate :format, to: :request
  delegate :html?, to: :format

  def online_label
    '<span class="fw-semibold available-online">Available online <i class="bi bi-forward-fill"></i></span>'.html_safe
  end

  def stanford_only_icon
    context.render StanfordOnlyPopoverComponent.new
  end

  def online_access_panel?
    access_panel_links.present?
  end

  def access_panel_links
    document.preferred_online_links || []
  end

  def document_has_fulltext?
    document.html_fulltext? && !online_access_panel?
  end

  def render_fulltext_link(link)
    if link.href == 'detail' # PDFs
      detail_link_markup(link)
    elsif link.ill?
      link_to(link.text, link.href, class: 'sfx')
    else
      "#{online_label} #{link_to(link.text, link.href)}"
    end
  end

  def detail_link_markup(link)
    <<-HTML
      #{online_label}
      #{(link_to('View on detail page', eds_document_url(document)) if document_has_fulltext?)}
      #{image_tag(image_url('pdf-icon.svg'), height: '20px', alt: 'PDF')}
      #{link_to(link.text, article_fulltext_link_url(id: document.id, type: link.type), data: { turbo: false })}
      #{stanford_only_icon}
    HTML
  end
end
