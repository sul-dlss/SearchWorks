# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  def clear
    if current_or_guest_user.bookmarks.clear
      flash[:success] = I18n.t('blacklight.bookmarks.clear.success')
    else
      flash[:error] = I18n.t('blacklight.bookmarks.clear.failure')
    end
    redirect_back fallback_location: bookmarks_url
  end
end
