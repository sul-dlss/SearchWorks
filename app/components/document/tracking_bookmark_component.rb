# frozen_string_literal: true

# Overridden from Blacklight to attach analytics
module Document
  class TrackingBookmarkComponent < Blacklight::Document::BookmarkComponent
    def initialize(display_label: false, **)
      super
      @display_label = display_label
    end

    def icon
      tag.i '',
            data: { bookmark_target: 'icon' },
            class: "bi #{bookmarked? ? 'bi-bookmark-check-fill' : 'bi-bookmark-plus'}",
            aria_hidden: true
    end

    # Did the request come from a record view page?  If so, we want to display a label next to the button.
    def display_label?
      @display_label
    end

    def label
      tag.span bookmarked? ? "Saved" : "Save", class: 'bookmark-label ms-1'
    end
  end
end
