###
#  Helper module for catalog controller behavior
###
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def render_view_type_group_icon(view)
    content_tag(
      :i,
      '',
      class: "fa #{blacklight_config.view[view].icon_class || default_view_type_group_icon_classes(view)}"
    )
  end

  def current_view
    params[:view] ? params[:view] : 'list'
  end

  def location_level_request_link?(library, location)
    return false if location.reserve_location?
    library.location_level_request? || location.location_level_request?
  end
end
