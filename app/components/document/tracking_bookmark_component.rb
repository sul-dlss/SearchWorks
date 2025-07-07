# frozen_string_literal: true

# Overridden from Blacklight to attach analytics
module Document
  class TrackingBookmarkComponent < Blacklight::Document::BookmarkComponent
    def icon
      tag.i '',
            data: { bookmark_target: 'icon' },
            class: "bi #{bookmarked? ? 'bi-bookmark-check-fill' : 'bi-bookmark-plus'}",
            aria_hidden: true
    end
  end
end
