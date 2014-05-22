class HoursController < ApplicationController
  def show
    response = HoursRequest.new(params[:library]).get
    respond_to do |format|
      format.json { render json: response }
    end
  end
end
