# frozen_string_literal: true

###
#  Helper module for catalog controller behavior
###
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # override upstream so we don't check the session for the last view type.
  def document_index_view_type(query_params = params || {})
    view_param = query_params[:view]
    return view_param.to_sym if view_param && document_index_views.key?(view_param.to_sym)

    default_document_index_view_type
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

  # Override Blacklight, which has a bug when the facet url key doesn't match the solr field name
  # Render an html <title> appropriate string for a selected facet field and values
  #
  # @see #render_search_to_page_title
  # @param [Symbol] facet the facet field
  # @param [Array<String>] values the selected facet values
  # @return [String]
  def render_search_to_page_title_filter(facet, values)
    facet_config = blacklight_config.facet_fields[facet] || facet_configuration_for_field(facet)
    facet_presenter = facet_field_presenter(facet_config, {})
    filter_label = facet_presenter.label
    filter_value = if values.size < 3
                     values.map do |value|
                       item_presenter = facet_presenter.item_presenter(value)
                       label = item_presenter.label
                       label = strip_tags(label) if label.html_safe?
                       label
                     end.to_sentence
                   else
                     t('blacklight.search.page_title.many_constraint_values', values: values.size)
                   end
    t('blacklight.search.page_title.constraint', label: filter_label, value: filter_value)
  end
end
