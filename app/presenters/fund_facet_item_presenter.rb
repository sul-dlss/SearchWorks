# frozen_string_literal: true

# We are presenting book funds in gallery mode. This resets view when the fund constraint is removed.
class FundFacetItemPresenter < Blacklight::FacetItemPresenter
  def remove_href(path = search_state)
    params_without_facet = path.filter(facet_config.key).remove(facet_item).to_h
    view_context.search_action_path(params_without_facet.except(:view))
  end
end
