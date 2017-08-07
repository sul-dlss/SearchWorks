module QuickSearch
  class CatalogSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= CatalogSearchService.new.search(params[:q])
    end
  end
end
