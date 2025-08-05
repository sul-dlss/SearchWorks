# frozen_string_literal: true

class AvailabilityController < ApplicationController
  include Blacklight::Searchable

  before_action :redirect_bots
  layout 'turbo_rails/frame'

  def show
    # Unfortunately, FOLIO doesn't provide enough information in the RTAC lookup to drive all of our logic,
    # so we also need to retrieve the solr document too.
    @document = search_service.fetch(params[:id])
    @rtac = LiveLookup.new(@document[:uuid_ssi]).records.index_by { |record| record[:item_id] }
  rescue FolioClient::Error => e
    Honeybadger.notify e
  end

  private

  def redirect_bots
    if /bot|spider|crawl|teoma/i.match?(request.env['HTTP_USER_AGENT'])
      render status: :forbidden, plain: "No bots allowed"
    end
  end
end
