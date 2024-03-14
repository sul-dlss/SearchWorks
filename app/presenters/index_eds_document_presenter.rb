# frozen_string_literal: true

class IndexEdsDocumentPresenter < Blacklight::IndexPresenter
  include PresenterFormat

  def heading(*)
    original = super
    return SolrDocument::UPDATED_EDS_RESTRICTED_TITLE if SolrDocument::EDS_RESTRICTED_PATTERN.match?(original)

    original
  end
end
