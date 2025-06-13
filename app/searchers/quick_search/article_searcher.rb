# frozen_string_literal: true

module QuickSearch
  class ArticleSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::ArticleSearchService

    def see_all_url_template
      Settings.ARTICLE.QUERY_URL
    end
  end
end
