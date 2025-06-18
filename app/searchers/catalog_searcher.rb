# frozen_string_literal: true

class CatalogSearcher < ApplicationSearcher
  self.search_service = ::CatalogSearchService
end
