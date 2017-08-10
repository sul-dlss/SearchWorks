module QuickSearch
  class CatalogSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::CatalogSearchService.new.search(q)
    end

    def loaded_link
      Settings.CATALOG_QUERY_URL.to_s % { q: URI.escape(q.to_s) }
    end
  end
end
