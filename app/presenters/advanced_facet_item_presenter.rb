# frozen_string_literal: true

class AdvancedFacetItemPresenter < Blacklight::FacetGroupedItemPresenter
  # The main difference here is we are sending in a facet item which is a Blacklight::Solr::Response::Facets::FacetItem
  # and not just a value
  def selected?
    group.include?(facet_item.value)
  end

  # Removal link for inclusive facets that are selected
  def remove_href(path = search_state)
    new_state = path.filter(facet_config).remove(group)
    new_state = new_state.filter(facet_config).add(group - [facet_item.value])

    view_context.search_action_path(new_state)
  end

  # Addition link for inclusive facets that have NOT been selected
  # The main override from FacetGroupedItemPresenter is the use of facet_item.value instead of facet_item
  def add_href(_path_options = {})
    return view_context.public_send(facet_config.url_method, facet_config.key, facet_item.value) if facet_config.url_method

    new_state = search_state.filter(facet_config).remove(@group)
    new_state = new_state.filter(facet_config).add(@group + [facet_item.value])

    view_context.search_action_path(new_state)
  end
end
