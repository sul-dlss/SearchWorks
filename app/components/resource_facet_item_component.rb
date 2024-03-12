# frozen_string_literal: true

class ResourceFacetItemComponent < Blacklight::FacetItemComponent
  def render_facet_value(...)
    resource_icon + super
  end

  def render_selected_facet_value(...)
    resource_icon + super
  end

  def resource_icon
    helpers.render_resource_icon(@facet_item.value)
  end
end
