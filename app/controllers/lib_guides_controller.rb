# frozen_string_literal: true

class LibGuidesController < ApplicationController
  def index
    render json: LibGuidesApi.fetch(params[:q])
  end
end
