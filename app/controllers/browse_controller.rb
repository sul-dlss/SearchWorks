class BrowseController < ApplicationController
  include Blacklight::Catalog::SearchContext
  include Blacklight::Configurable
  include Blacklight::SolrHelper
  copy_blacklight_config_from(CatalogController)

  def index
    if params[:start].present?
      @response, @original_doc = get_solr_response_for_doc_id(params[:start])
      barcode = params[:barcode] || @original_doc[:preferred_barcode]
      respond_to do |format|
        format.html do 
          @document_list = NearbyOnShelf.new(
            "static",
            blacklight_config,
            {:item_display => @original_doc[:item_display],
             :preferred_barcode=>barcode,
             :before => 9,
             :after => 10,
             :page => params[:page]}
          ).items.map do |document|
            SolrDocument.new(document[:doc])
          end
        end
      end
    end
  end
  private
  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  def thumbnail(document, options = {})
    view_context.render_cover_image(document, options)
  end
  helper_method :thumbnail
end
