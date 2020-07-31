# frozen_string_literal: true

class JsonResultsDocumentPresenter
  def initialize(source_document)
    @source_document = source_document
  end

  def as_json(*)
    transformations = [fulltext_link_html, temporary_access_link_html]

    source_document.as_json.tap do |json|
      transformations.each do |data|
        json.merge!(data)
      end
    end
  end

  private

  attr_reader :source_document

  def temporary_access_link_html
    return {} unless temporary_access_link

    {
      'temporary_access_link_html' => [
        "<span class=\"stanford-only\">#{temporary_access_link}</span>"
      ]
    }
  end

  def temporary_access_link
    return unless source_document&.access_panels&.temporary_access?

    source_document&.access_panels&.temporary_access&.link&.html
  end

  def fulltext_link_html
    return {} if online_links.blank?

    {
      'fulltext_link_html' => online_links.map do |link|
        html = link.stanford_only? ? "<span class=\"stanford-only\">#{link.html}</span>" : link.html

        "<span class=\"online-label\">Online</span> #{html}"
      end
    }
  end

  def online_links
    return [] unless source_document&.access_panels&.online?

    source_document&.access_panels&.online&.links
  end
end
