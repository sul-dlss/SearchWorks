# frozen_string_literal: true

class RecordToolbarComponent < ViewComponent::Base
  def initialize(presenter:, search_context:)
    @presenter = presenter
    @search_context = search_context
    super()
  end

  delegate :document, to: :@presenter
  delegate :citable?, to: :document

  def cite_path
    document.eds? ? citation_article_path(document) : citation_solr_document_path(document)
  end
end
