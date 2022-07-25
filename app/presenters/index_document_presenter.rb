class IndexDocumentPresenter < Blacklight::IndexPresenter
  include PresenterFormat

  def display_type(*)
    document.display_type
  end
end
