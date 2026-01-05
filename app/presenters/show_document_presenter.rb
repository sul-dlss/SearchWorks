# frozen_string_literal: true

class ShowDocumentPresenter < Blacklight::ShowPresenter
  include PresenterFormat
  include CatalogFields

  delegate :sanitize, to: :view_context

  delegate :vernacular_title, :citations, to: :document

  def html_title
    sanitize super, tags: []
  end
end
