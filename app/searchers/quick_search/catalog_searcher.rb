# frozen_string_literal: true

module QuickSearch
  class CatalogSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::CatalogSearchService

    def see_all_url_template
      Settings.CATALOG.QUERY_URL
    end
  end
end
