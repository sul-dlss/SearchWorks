# frozen_string_literal: true

module QuickSearch
  class LibraryWebsiteApiSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::LibraryWebsiteApiSearchService

    def see_all_url_template
      Settings.library_website.query_url
    end
  end
end
