# frozen_string_literal: true

# Overridden from Blacklight for articles to inject custom parameters
module Articles
  module Document
    class BookmarkComponent < Blacklight::Document::BookmarkComponent
      attr_reader :document

      def bookmark_icon
        render Icons::BookmarkIconComponent.new(name: 'bookmark', data: { bookmark_target: 'icon' })
      end
    end
  end
end
