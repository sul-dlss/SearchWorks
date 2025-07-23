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

    def aria_label
      [tooltip_label, bookmark_subject_label].join(' ')
    end

    def tooltip_label
      bookmarked? ? "Remove from saved records" : "Save record"
    end

    def bookmark_state_label
      bookmarked? ? t('blacklight.search.bookmarks.present') : t('blacklight.search.bookmarks.absent')
    end

    private

    def bookmark_subject_label
      helpers.document_presenter(@document)&.heading || @document.id
    end
  end
end
