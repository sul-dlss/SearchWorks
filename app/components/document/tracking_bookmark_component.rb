# frozen_string_literal: true

# Overridden from Blacklight to attach analytics
module Document
  class TrackingBookmarkComponent < Blacklight::Document::BookmarkComponent
    def bookmark_icon
      render Icons::BookmarkIconComponent.new(name: 'bookmark', classes: 'btn p-1 lh-1 action-button', data: { bookmark_target: 'icon' })
    end

    def article?
      @document.eds?
    end
  end
end
