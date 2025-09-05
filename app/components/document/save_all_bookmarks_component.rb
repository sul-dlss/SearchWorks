# frozen_string_literal: true

module Document
  class SaveAllBookmarksComponent < ViewComponent::Base
    attr_reader :documents_selector

    def initialize(documents_selector:)
      super()

      @documents_selector = documents_selector
    end

    def icon
      render Icons::BookmarkIconComponent.new(name: 'bookmark', classes: 'action-button toggle-bookmark-label', data: { bookmark_target: 'icon' })
    end
  end
end
