# frozen_string_literal: true

class BrowseController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  include Blacklight::SearchContext

  copy_blacklight_config_from(CatalogController)

  before_action :fetch_orginal_document
  before_action :fetch_browse_items
  before_action :fetch_bookmarks
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

  # Wipe out the search state; none of the normal search parameters are relevant
  def search_state
    @search_state ||= search_state_class.new({}, blacklight_config, self)
  end

  def browse_params
    params.permit(:start, :barcode, :before, :after, :view, :call_number)
  end

  def fetch_orginal_document
    @original_doc = search_service.fetch(params[:start]) if params[:start]
    # NOTE: In Blacklight 8, #fetch does not return a response object, so we stub one out to satisfy:
    # https://github.com/projectblacklight/blacklight/blob/v7.36.2/app/helpers/blacklight/catalog_helper_behavior.rb#L292
    @document = @original_doc
  end

  def fetch_browse_items
    if params[:before] || params[:after] || params[:start].blank?
      service = if params[:before]
                  NearbyOnShelf.reverse(search_service:)
                else
                  NearbyOnShelf.forward(search_service:)
                end

      @spines = service.spines(params[:before] || params[:after])
    else
      spine = @original_doc.browseable_spines.find { |c| c.base_callnumber == params[:call_number] }
      spine ||= @original_doc.browseable_spines.find { |c| c.base_callnumber == @original_doc.preferred_item.truncated_callnumber } if @original_doc.preferred_item
      spine ||= @original_doc.browseable_spines.first

      @spines = NearbyOnShelf.around_spine(
        spine,
        search_service:
      )
    end
  end

  def fetch_bookmarks
    @current_bookmarks = current_or_guest_user.bookmarks
  end
end
