class BrowseController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  include Blacklight::SearchContext
  include Thumbnail
  copy_blacklight_config_from(CatalogController)

  before_action do
    blacklight_config.track_search_session = false
  end

  def index
    if params[:start].present?
      @response, @original_doc = search_service.fetch(params[:start])
      barcode = params[:barcode] || @original_doc[:preferred_barcode]
      respond_to do |format|
        format.html do
          @document_list = NearbyOnShelf.new(
            "static",
            search_service,
            { item_display: @original_doc[:item_display],
             preferred_barcode: barcode,
             before: 9,
             after: 10,
             page: params[:page] }
          ).items.pluck(:doc)
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
            "static",
            search_service,
            { item_display: @original_doc[:item_display],
             preferred_barcode: barcode,
             before: 12,
             after: 12 }
          ).items.pluck(:doc)
          render browse: @document_list, layout: false
        end
      end
    end
  end

  private

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end
end
