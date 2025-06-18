# frozen_string_literal: true

class LibraryWebsiteApiSearcher < ApplicationSearcher
  self.search_service = ::LibraryWebsiteApiSearchService
end
