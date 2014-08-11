module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def render_view_type_group_icon view
    content_tag :i, '', class: "fa #{blacklight_config.view[view].icon_class || default_view_type_group_icon_classes(view) }"
  end
  def current_view
    params[:view] ? params[:view] : 'list'
  end
end
