class BrowseController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  include Blacklight::SearchContext
  include Thumbnail

  helper_method :browse_params

  copy_blacklight_config_from(CatalogController)

  def index
    if params[:start].present?
      @response, @original_doc = search_service.fetch(params[:start])
      barcode = params[:barcode] || @original_doc[:preferred_barcode]
      respond_to do |format|
        format.html do
          @document_list = NearbyOnShelf.new(
            item_display: @original_doc[:item_display],
            barcode: barcode,
            page: params[:page].to_i,
            search_service: search_service
          ).document_list
        end
      end
    end
  end

  def nearby
    if params[:start].present?
      @response, @original_doc = search_service.fetch(params[:start])
      barcode = params[:barcode] || @original_doc[:preferred_barcode]
      respond_to do |format|
        format.html do
          @document_list = NearbyOnShelf.new(
            item_display: @original_doc[:item_display],
            barcode: barcode,
            search_service: search_service
          ).document_list
          render layout: false
        end
      end
    end
  end

  private

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  def browse_params
    params.permit(:start, :page, :barcode)
  end
end
