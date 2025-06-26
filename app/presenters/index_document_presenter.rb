# frozen_string_literal: true

class IndexDocumentPresenter < Blacklight::IndexPresenter
  include PresenterFormat
  include CatalogFields
end
