# frozen_string_literal: true

class JsonResultsDocumentPresenter
  def initialize(source_document, view_context)
    @source_document = source_document
    @view_context = view_context
  end

  def as_json(*)
    transformations = [fulltext_link_html]

    source_document.as_json.tap do |json|
      transformations.each do |data|
        json.merge!(data)
      end
    end
  end

  private

  attr_reader :source_document

  def fulltext_link_html
    return {} if online_links.blank?

    {
      'fulltext_link_html' => online_links.map do |link|
        access_link = Searchworks4::AccessLinkComponent.new(link:).render_in(@view_context)
        html = link.stanford_only? ? "<span class=\"stanford-only\">#{access_link}</span>" : access_link

        "<span class=\"online-label\">Online</span> #{html}"
      end
    }
  end

  def online_links
    return [] unless source_document&.preferred_online_links&.any?

    source_document.preferred_online_links
  end
end
