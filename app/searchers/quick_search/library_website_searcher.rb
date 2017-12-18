module QuickSearch
  class LibraryWebsiteSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::LibraryWebsiteSearchService.new.search(q)
    end

    def loaded_link
      Settings.LIBRARY_WEBSITE_QUERY_API_URL.to_s % { q: CGI.escape(q.to_s) }
    end
  end
end
