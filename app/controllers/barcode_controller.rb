# frozen_string_literal: true

class BarcodeController < ApplicationController
  def show
    render json: BarcodeSearch.new(params[:id])
  end
end
