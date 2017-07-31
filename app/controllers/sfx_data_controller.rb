##
# A controller to asynchronously request SFX HTML
class SfxDataController < ApplicationController
  before_action :setup_sfx_data

  def show
    if @sfx_data.targets.present?
      render layout: false
    else
      render status: :not_found, layout: false, file: Rails.root.join('public', '404.html')
    end
  end

  private

  def setup_sfx_data
    url = CGI.unescape(params.fetch(:url))

    @sfx_data = SfxData.new(url)
  end
end
