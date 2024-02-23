###
#  Helper module for catalog controller behavior
###
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

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
    document_index_view_type.to_s || 'list'
  end

  def stackmap_link(document, location)
    item = location.items.first
    stackmap_path(title: (document['title_display'] || '').html_safe, id: document.id, callnumber: item.callnumber, library: item.library, location: item.effective_permanent_location_code, api_url: location.stackmap_api_url)
  end

  def new_documents_feed_path
    search_catalog_path(
      search_state.to_h.except(:controller, :action, :page, :format, :sort).to_hash.merge(sort: 'new-to-libs', format: 'atom')
    )
  end

  def link_to_bookplate_search(bookplate, link_opts = {})
    link_to(
      bookplate.text,
      search_catalog_path(bookplate.params_for_search.merge(view: 'gallery', sort: 'new-to-libs')),
      link_opts
    )
  end

  def link_to_database_search(subject)
    link_to(subject, search_catalog_path(f: { db_az_subject: [subject], SolrDocument::FORMAT_KEY => ['Database'] }))
  end

  def grouped_citations(documents)
    Citation.grouped_citations(documents.map(&:citations))
  end

  def tech_details(document)
    details = []
    details.push link_to(
      t('blacklight.tools.librarian_view'),
      librarian_view_path(document), id: 'librarianLink', data: { blacklight_modal: 'trigger' }
    )
    details.push link_to('Collection PURL', "https://purl.stanford.edu/#{document.druid}") if document.is_a_collection?
    if document.respond_to?(:to_marc)
      details.push "Catkey: #{document[:id]}"
    elsif document.mods?
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
    link_url = format Settings.IIIF_DND_BASE_URL, query: { manifest: }.to_query
    link_to(
      link_url,
      class: 'iiif-dnd pull-right',
      data: { turbo: false, toggle: 'tooltip', placement: position, manifest: },
      title: 'Drag icon to any IIIF viewer. — Click icon to learn more.'
    ) do
      image_tag 'iiif-drag-n-drop.svg', width:, alt: 'IIIF Drag-n-drop'
    end
  end
end
