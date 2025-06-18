# frozen_string_literal: true

class ExhibitsSearcher < ApplicationSearcher
  self.search_service = ::ExhibitsSearchService
end
