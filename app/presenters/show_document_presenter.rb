# frozen_string_literal: true

class ShowDocumentPresenter < Blacklight::ShowPresenter
  include PresenterFormat

  delegate :sanitize, to: :view_context

  def html_title
    sanitize super, tags: []
  end

  def display_type(*)
    document.display_type
  end
end
