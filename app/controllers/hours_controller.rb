class HoursController < ApplicationController
  def show
    response = HoursRequest.new(params[:id]).get
    respond_to do |format|
      format.json { render json: response }
      format.html { render 'public/500', layout: false, status: 400 }
    end
  end
end
