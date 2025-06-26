# frozen_string_literal: true

# Overridden from Blacklight to attach analytics
module Document
  class TrackingBookmarkComponent < Blacklight::Document::BookmarkComponent
  end
end
