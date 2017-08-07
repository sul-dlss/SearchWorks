module QuickSearch
  class ArticleSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ArticleSearchService.new.search(params[:q])
    end
  end
end
