# frozen_string_literal: true

module QuickSearch
  class LibGuidesSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::LibGuidesSearchService

    def see_all_url_template
      Settings.LIBGUIDES.QUERY_URL
    end
  end
end
