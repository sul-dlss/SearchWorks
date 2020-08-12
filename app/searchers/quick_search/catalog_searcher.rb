# frozen_string_literal: true

module QuickSearch
  class CatalogSearcher < QuickSearch::ApplicationSearcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::CatalogSearchService.new(http: http).search(q)
    end

    def loaded_link
      format(Settings.CATALOG.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
