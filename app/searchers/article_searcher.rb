# frozen_string_literal: true

class ArticleSearcher < ApplicationSearcher
  self.search_service = ::ArticleSearchService
end
