class RecentSelectionsController < ApplicationController
  def index
    redirect_to(root_url) unless request.xhr?

    @catalog_count = current_or_guest_user.bookmarks.where(record_type: 'catalog').count
    @article_count = current_or_guest_user.bookmarks.where(record_type: 'article').count

    respond_to do |format|
      format.html do
        render layout: false
      end
    end
  end
end
