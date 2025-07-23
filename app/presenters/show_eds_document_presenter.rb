# frozen_string_literal: true

class ShowEdsDocumentPresenter < Blacklight::ShowPresenter
  include PresenterFormat
  include CatalogFields

  delegate :citations, to: :document
end
