# frozen_string_literal: true

module QuickSearch
  class LibGuidesSearcher < QuickSearch::ApplicationSearcher
    delegate :results, :total, to: :search

    def search
      @search ||= ::LibGuidesSearchService.new(http: http).search(q)
    end

    def loaded_link
      format(Settings.LIBGUIDES.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
