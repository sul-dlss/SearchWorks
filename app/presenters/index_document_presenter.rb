# frozen_string_literal: true

class IndexDocumentPresenter < Blacklight::IndexPresenter
  include PresenterFormat

  def display_type(*)
    document.display_type
  end
end
