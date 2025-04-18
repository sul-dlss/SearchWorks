# frozen_string_literal: true

##
# A controller to asynchronously request SFX HTML
class SfxDataController < ApplicationController
  before_action :setup_sfx_data

  def show
    if @sfx_data.targets.present?
      render layout: false
    else
      render Status::NotFoundComponent.new, status: :not_found
    end
  end

  private

  def setup_sfx_data
    @sfx_data = SfxData.new(params.fetch(:url))
  end
end
