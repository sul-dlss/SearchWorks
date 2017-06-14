class BrowseController < ApplicationController
  include Blacklight::SearchContext
  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include Thumbnail
  copy_blacklight_config_from(CatalogController)

  def index
    if params[:start].present?
      @response, @original_doc = fetch(params[:start])
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

  def nearby
    if params[:start].present?
      @response, @original_doc = fetch(params[:start])
      barcode = params[:barcode] || @original_doc[:preferred_barcode]
      respond_to do |format|
        format.html do
          @document_list = NearbyOnShelf.new(
            "static",
            blacklight_config,
            {:item_display => @original_doc[:item_display],
             :preferred_barcode=>barcode,
             :before => 12,
             :after => 12}
          ).items.map do |document|
            SolrDocument.new(document[:doc])
          end
          render browse: @document_list, layout:false
        end
      end
    end
  end

  private
  def _prefixes
    @_prefixes ||= super + ['catalog']
  end
end
