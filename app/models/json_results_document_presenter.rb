# frozen_string_literal: true

class JsonResultsDocumentPresenter
  def initialize(source_document)
    @source_document = source_document
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

    { 'links' => online_links.map(&:as_json) }
  end

  def online_links
    source_document&.preferred_online_links || []
  end
end
