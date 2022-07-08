class ShowDocumentPresenter < Blacklight::ShowPresenter
  include PresenterFormat
  include PresenterResearchStarter

  def heading
    original = super
    return SolrDocument::UPDATED_EDS_RESTRICTED_TITLE if original =~ SolrDocument::EDS_RESTRICTED_PATTERN

    original
  end

  def display_type(*)
    document.display_type
  end
end
