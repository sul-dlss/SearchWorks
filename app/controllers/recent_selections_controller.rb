class RecentSelectionsController < ApplicationController

  include Blacklight::SearchHelper
  include Blacklight::SearchContext
  def index
    _, @recent_selections =
      fetch(
        current_or_guest_user.bookmarks.last(3).map(&:document_id)
      )
    if request.xhr?
      respond_to do |format|
        format.html do
          render recent_selections: @recent_selections, layout: false
        end
      end
    else
      redirect_to root_url
    end
  end
end
