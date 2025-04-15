# frozen_string_literal: true

class ErrorsController < ApplicationController
  def show
    @code = params[:code] || '500'

    render Status::NotFoundComponent.new, status: @code
  end
end
