module QuickSearch
  class ArticleSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::ArticleSearchService.new.search(q)
    end

    def loaded_link
      Settings.EDS_QUERY_URL.to_s % { q: URI.escape(q.to_s) }
    end
  end
end
