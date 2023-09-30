class ToolbarSearchContextInfoComponent < Blacklight::SearchContext::ServerItemPaginationComponent
  def link_to_next_document(*args)
    helpers.link_to_next_document(*args)
  end

  def link_to_previous_document(*args)
    helpers.link_to_previous_document(*args)
  end
end
