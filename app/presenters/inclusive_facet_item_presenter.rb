class InclusiveFacetItemPresenter < Blacklight::FacetGroupedItemPresenter
  # The main difference here is we are sending in a facet item which is a Blacklight::Solr::Response::Facets::FacetItem
  # and not just a value
  def selected?
    group.include?(facet_item.value)
  end

  def remove_href(path = search_state)
    new_state = path.filter(facet_config).remove(group)
    new_state = new_state.filter(facet_config).add(group - [facet_item.value])

    view_context.search_action_path(new_state)
  end
end