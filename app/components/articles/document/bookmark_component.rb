# frozen_string_literal: true

# Overridden from Blacklight for articles to inject custom parameters
module Articles
  module Document
    class BookmarkComponent < Blacklight::Document::BookmarkComponent
      attr_reader :document
    end
  end
end
