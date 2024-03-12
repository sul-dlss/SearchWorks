# frozen_string_literal: true

class AvailabilityController < ApplicationController
  before_action :redirect_bots, :redirect_no_ids
  def index
    render json: LiveLookup.new(params[:ids]).as_json, layout: false
  end

  private

  def redirect_bots
    if /bot|spider|crawl|teoma/.match?(request.env['HTTP_USER_AGENT'])
      render status: :forbidden, plain: "No bots allowed"
    end
  end

  def redirect_no_ids
    render json: [] unless params[:ids].present?
  end
end
