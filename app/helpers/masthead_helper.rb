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

  def back_icon
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-forward-fill ps-1" viewBox="0 0 16 16" style="transform: rotate(180deg);">
      <path d="m9.77 12.11 4.012-2.953a.647.647 0 0 0 0-1.114L9.771 5.09a.644.644 0 0 0-.971.557V6.65H2v3.9h6.8v1.003c0 .505.545.808.97.557"/>
    </svg>'.html_safe # rubocop:disable Rails/OutputSafety
  end
end
