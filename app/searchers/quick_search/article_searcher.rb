# frozen_string_literal: true

module QuickSearch
  class ArticleSearcher < QuickSearch::ApplicationSearcher
    delegate :results, :total, :facets, to: :search

    def search
      @response ||= ::ArticleSearchService.new(http: http).search(q)
    end

    def loaded_link
      format(Settings.ARTICLE.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
