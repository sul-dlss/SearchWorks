# frozen_string_literal: true

xml.instruct! :xml, version: "1.0", encoding: "utf-8"
xml.response {
  cover_hash = {}
  cover_hash = get_covers_for_mobile(@response) unless (params.has_key?(:covers) and params[:covers] == "false") or drupal_api?
  @document_list.each do |doc|
    xml.LBItem do
      xml << render(partial: "#{params[:controller]}/#{params[:action]}_default", locals: { doc:, cover_hash: })
    end # xml.LBItem
  end # @response.docs.each
  xml.TCPagingResult do
    page_size = params[:per_page] ? params[:per_page] : blacklight_config.default_solr_params[:per_page]
    start_index = (page_size.to_i * (params[:page] ? params[:page].to_i - 1 : 0).to_i).to_s
    total = @response.response['numFound']
    xml.start_index(start_index)
    xml.total_results(total)
    xml.page_size(page_size)
    # This tests if the current number of docs is the same size as the per_page.  If it's less, we should be on the last page
    xml.has_more_page(page_size.to_i == @response.docs.length.to_i)
  end
} #end xml.data
