# frozen_string_literal: true

###
#  Helper module for contents rendered in mastheads
###
module MastheadHelper
  def render_masthead_partial
    return unless page_location.access_point?

    begin
      render "catalog/mastheads/#{page_location.access_point}"
    rescue ActionView::MissingTemplate
      return
    end
  end

  def page_location
    PageLocation.new(search_state)
  end

  def sdr_path
    facet_params = { f: { building_facet: ['Stanford Digital Repository'] } }
    search_catalog_path(facet_params)
  end

  def digital_collection_path
    facet_params = { f: { collection_type: ['Digital Collection'] } }
    search_catalog_path(facet_params)
  end

  def iiif_item_path
    facet_params = { f: { iiif_resources: ['available'] } }
    search_catalog_path(facet_params)
  end

  def bookplate_from_document_list(response = @response)
    return unless params[:f] && params[:f][:fund_facet].present? && response.docs.present?

    SolrDocument.new(response.docs.first.to_h).bookplates.find do |bookplate|
      bookplate.matches? params
    end
  end

  def bookplate_breadcrumb_value(druid, response = @response)
    return druid unless response.docs.present?

    bookplate_from_document_list.try(:text) || druid
  end
end
