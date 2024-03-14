# frozen_string_literal: true

###
#  Helper module for contents rendered in mastheads
###
module MastheadHelper
  def render_masthead_partial
    return '' unless page_location.access_point?

    begin
      render "catalog/mastheads/#{page_location.access_point}"
    rescue ActionView::MissingTemplate
      return ''
    end
  end

  def page_location
    PageLocation.new(search_state)
  end

  def facets_prefix_options
    ['0-9', ('A'..'Z').to_a].flatten
  end

  def digital_collections_params_for(format = nil)
    facet_params = { f: { building_facet: ['Stanford Digital Repository'] } }
    facet_params[:f][:format_main_ssim] = [format] if format
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
