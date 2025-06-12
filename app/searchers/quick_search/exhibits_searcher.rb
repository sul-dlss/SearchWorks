# frozen_string_literal: true

module QuickSearch
  class ExhibitsSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::ExhibitsSearchService

    def see_all_url_template
      Settings.exhibits.query_url
    end
  end
end
