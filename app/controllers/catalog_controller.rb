class CatalogController < ApplicationController
  def index
    @response = CatalogSearchService.new.search(params[:q])
  end
end
