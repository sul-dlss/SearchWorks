# frozen_string_literal: true

###
#  Helper module for catalog controller behavior
###
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def current_view
    document_index_view_type.to_s
  end

  def stackmap_link(document, location)
    item = location.items.first
    params = { callno: item.callnumber,
               library: item.library,
               location: item.effective_permanent_location_code }
    uri = URI(location.stackmap_api_url)
    uri.query = params.to_query
    stackmap_path(title: (document['title_display'] || '').html_safe,
                  api_url: uri.to_s,
                  id: document.id)
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
      data: { turbo: false, action: "dragstart->analytics#trackEvent", 'bs-toggle': 'tooltip', 'bs-placement': position, manifest: },
      title: 'Drag icon to any IIIF viewer. — Click icon to learn more.'
    ) do
      image_tag 'iiif-drag-n-drop.svg', width:, alt: 'IIIF Drag-n-drop'
    end
  end

  def html_present?(value)
    return false if value.blank?

    value.gsub(/<!--.*?-->/m, '').present?
  end
end
