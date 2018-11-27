# frozen_string_literal: true

module QuickSearch
  class ArticleSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :search

    def search
      @response ||= ::ArticleSearchService.new.search(q)
    end

    def loaded_link
      format(Settings.EDS_QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
