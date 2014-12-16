class EmbedController < ApplicationController
  def show
    respond_to do |format|
      format.json { render json: { html: PURLEmbed.new(params[:id]).html } }
    end
  end
end