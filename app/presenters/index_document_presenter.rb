class IndexDocumentPresenter < Blacklight::IndexPresenter
  include PresenterFormat

  def label(*)
    original = super
    return SolrDocument::UPDATED_EDS_RESTRICTED_TITLE if original =~ SolrDocument::EDS_RESTRICTED_PATTERN

    original
  end
end
