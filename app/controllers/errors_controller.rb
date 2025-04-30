# frozen_string_literal: true

class ErrorsController < ApplicationController
  COMPONENT_FOR_STATUS = {
    '404' => Status::NotFoundComponent,
    '500' => Status::ServerErrorComponent
  }.freeze

  def show
    @code = params[:code] || '500'

    render COMPONENT_FOR_STATUS[@code].new, status: @code
  end
end
