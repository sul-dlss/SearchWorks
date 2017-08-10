class ArticleController < ApplicationController
  def index
    @response = ArticleSearchService.new.search(params[:q])
  end
end
