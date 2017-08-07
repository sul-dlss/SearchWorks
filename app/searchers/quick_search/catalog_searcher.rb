module QuickSearch
  class CatalogSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::CatalogSearchService.new.search(q)
    end
  end
end
