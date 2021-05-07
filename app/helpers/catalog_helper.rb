###
#  Helper module for catalog controller behavior
###
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def document_partial_name(document, base_name = nil)
    view_config = blacklight_config.view_config(:show)

    display_type = if base_name and view_config.has_key? :"#{base_name}_display_type_field"
      document[view_config[:"#{base_name}_display_type_field"]]
    end

    display_type ||= document.display_type

    display_type ||= document[view_config.display_type_field]

    display_type ||= 'default'

    type = type_field_to_partial_name(document, display_type)

    type
  end

  def catalog_search?
    controller_name == 'catalog'
  end

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
    return if location.reserve_location?
    return if Constants::NON_REQUESTABLE_HOME_LOCS.include?(location.try(:code))

    library.location_level_request? || location.location_level_request?
  end

  def stackmap_link(document, location)
    callnumber = location.items.first
    stackmap_path(title: (document['title_display'] || '').html_safe, id: document.id, callnumber: callnumber.callnumber, library: callnumber.library, location: callnumber.home_location)
  end

  def new_documents_feed_path
    search_catalog_path(
      params.except(:controller, :action, :page, :format, :sort).to_hash.merge(sort: 'new-to-libs', format: 'atom')
    )
  end

  def link_to_bookplate_search(bookplate, link_opts = {})
    link_to(
      bookplate.text,
      search_catalog_path(bookplate.params_for_search.merge(view: 'gallery', sort: 'new-to-libs')),
      link_opts
    )
  end

  def grouped_citations(documents)
    Citation.grouped_citations(documents.map(&:citations))
  end

  def tech_details(document)
    details = []
    details.push link_to(
      t('blacklight.tools.librarian_view'),
      librarian_view_path(document), id: 'librarianLink', data: { ajax_modal: 'trigger' }
    )
    details.push link_to('Collection PURL', "https://purl.stanford.edu/#{document.druid}") if document.is_a_collection?
    if document.respond_to?(:to_marc)
      details.push "Catkey: #{document[:id]}"
    elsif document.mods.present?
      details.push "DRUID: #{document[:id]}"
    else
      details.push "ID: #{document[:id]}"
    end
    safe_join(details, ' | ')
  end

  ##
  # Creates a IIIF Drag 'n Drop link with IIIF logo
  # @param [String] manifest
  # @param [String, Number] width
  # @param [String] position
  def iiif_drag_n_drop(manifest, width: '40', position: 'left')
    link_url = format Settings.IIIF_DND_BASE_URL, query: { manifest: manifest }.to_query
    link_to(
      link_url,
      class: 'iiif-dnd pull-right',
      data: { turbolinks: false, toggle: 'tooltip', placement: position, manifest: manifest },
      title: 'Drag icon to any IIIF viewer. — Click icon to learn more.'
    ) do
      image_tag 'iiif-drag-n-drop.svg', width: width, alt: 'IIIF Drag-n-drop'
    end
  end
end
