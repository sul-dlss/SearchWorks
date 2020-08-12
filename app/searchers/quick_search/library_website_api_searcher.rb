# frozen_string_literal: true

module QuickSearch
  class LibraryWebsiteApiSearcher < QuickSearch::ApplicationSearcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::LibraryWebsiteApiSearchService.new(http: http).search(q)
    end

    def loaded_link
      format(Settings.LIBRARY_WEBSITE.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
