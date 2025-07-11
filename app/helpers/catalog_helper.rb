# frozen_string_literal: true

###
#  Helper module for catalog controller behavior
###
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def current_view
    document_index_view_type.to_s
  end

  # override upstream so we don't check the session for the last view type.
  def document_index_view_type(query_params = params || {})
    view_param = query_params[:view]
    return view_param.to_sym if view_param && document_index_views.key?(view_param.to_sym)

    default_document_index_view_type
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

  def html_present?(value)
    return false if value.blank?

    value.gsub(/<!--.*?-->/m, '').present?
  end
end
