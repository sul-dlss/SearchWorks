# frozen_string_literal: true

class HoursController < ApplicationController
  def show
    response = HoursRequest.new(params[:id]).get
    respond_to do |format|
      format.json { render json: response }
      format.html { render status: :bad_request, layout: false, file: Rails.root.join('public', '500.html') }
    end
  end
end
