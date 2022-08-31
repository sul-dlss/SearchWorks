class BrowseController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  include Blacklight::SearchContext
  include Thumbnail

  copy_blacklight_config_from(CatalogController)

  before_action :fetch_orginal_document
  before_action :fetch_browse_items
  helper_method :browse_params

  def index
    respond_to do |format|
      format.html
    end
  end

  def nearby
    respond_to do |format|
      format.html do
        render layout: false
      end
    end
  end

  private

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  def browse_params
    params.permit(:start, :barcode, :before, :after, :view)
  end

  def fetch_orginal_document
    @response, @original_doc = search_service.fetch(params[:start]) if params[:start]
  end

  def fetch_browse_items
    if params[:before] || params[:after] || params[:start].blank?
      service = if params[:before]
                  NearbyOnShelf.reverse(search_service: search_service)
                else
                  NearbyOnShelf.forward(search_service: search_service)
                end

      @items = service.items(params[:before] || params[:after])
    else
      barcode = params[:barcode] || @original_doc[:preferred_barcode]
      item = @original_doc.items.find { |c| c.barcode.starts_with?(barcode) }

      @items = NearbyOnShelf.around_item(
        item,
        search_service: search_service
      )
    end
  end
end
