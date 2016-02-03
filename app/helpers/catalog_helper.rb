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

  def stackmap_link(document,location)
    callnumber = location.items.first
    stackmap_path(title: (document['title_display'] || '').html_safe, id: document.id, callnumber: callnumber.callnumber, library: callnumber.library, location: callnumber.home_location)
  end

  def new_documents_feed_path
    catalog_index_path(
      params.except(:controller, :action, :page).merge(format: 'atom', sort: 'new-to-libs')
    )
  end

  def link_to_bookplate_search(bookplate, link_opts = {})
    link_to(
      bookplate.text,
      catalog_index_path(bookplate.params_for_search.merge(view: 'gallery', sort: 'new-to-libs')),
      link_opts
    )
  end

  def grouped_citations(documents)
    Citation.grouped_citations(documents.map(&:citations))
  end
end
