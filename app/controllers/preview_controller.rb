class PreviewController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::Searchable
  copy_blacklight_config_from(CatalogController)

  def show
    @response, @document = search_service.fetch(params[:id])
    respond_to do |format|
      format.html do
        render preview: @document, layout: false
      end
    end
  end

  private

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end
end
