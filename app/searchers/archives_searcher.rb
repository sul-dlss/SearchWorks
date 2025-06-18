# frozen_string_literal: true

class ArchivesSearcher < ApplicationSearcher
  self.search_service = ::ArchivesSearchService
end
