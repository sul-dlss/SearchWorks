class ShowDocumentPresenter < Blacklight::ShowPresenter
  include PresenterFormat
  include PresenterResearchStarter

  delegate :strip_tags, to: :view_context

    original
  end

  def display_type(*)
    document.display_type
  end
end
