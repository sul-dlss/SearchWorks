# frozen_string_literal: true

class RecordToolbarComponent < ViewComponent::Base
  def initialize(presenter:, search_context:, search_session:)
    @presenter = presenter
    @search_context = search_context
    @search_session = search_session
    super()
  end

  delegate :document, to: :@presenter
  delegate :citable?, to: :document

  attr_reader :search_session

  def cite_path
    document.eds? ? citation_article_path(document) : citation_solr_document_path(document)
  end
end
