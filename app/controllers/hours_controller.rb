class HoursController < ApplicationController
  def show
    response = HoursRequest.new(params[:id]).parse_hours
    respond_to do |format|
      format.json { render json: response }
    end
  end
end
