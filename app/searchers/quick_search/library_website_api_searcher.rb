# frozen_string_literal: true

module QuickSearch
  class LibraryWebsiteApiSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::LibraryWebsiteApiSearchService

    def see_all_url_template
      Settings.LIBRARY_WEBSITE.QUERY_URL
    end
  end
end
