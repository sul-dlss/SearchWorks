# frozen_string_literal: true

class AvailabilityController < ApplicationController
  before_action :redirect_bots
  before_action :redirect_no_ids, only: [:index]
  include Blacklight::Searchable
  layout false, only: [:index]
  layout 'turbo_rails/frame', only: [:show]

  def index
    render json: LiveLookup.new(params[:ids]).as_json, layout: false
  end

  def show
    # Unfortunately, FOLIO doesn't provide enough information in the RTAC lookup to drive all of our logic,
    # so we also need to retrieve the solr document too.
    @document = search_service.fetch(params[:id])
    @rtac = LiveLookup.new(params[:uuid_ssi]).records
    @items = @document.holdings.items.index_by(&:live_lookup_item_id)
  end

  private

  def redirect_bots
    if /bot|spider|crawl|teoma/i.match?(request.env['HTTP_USER_AGENT'])
      render status: :forbidden, plain: "No bots allowed"
    end
  end

  def redirect_no_ids
    render json: [] unless Array(params[:ids]).compact_blank.present?
  end
end
