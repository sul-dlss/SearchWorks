# frozen_string_literal: true

module QuickSearch
  class ArticleSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::ArticleSearchService

    def see_all_url_template
      Settings.article.query_url
    end
  end
end
