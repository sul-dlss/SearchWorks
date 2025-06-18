# frozen_string_literal: true

class LibGuidesSearcher < ApplicationSearcher
  self.search_service = ::LibGuidesSearchService
end
