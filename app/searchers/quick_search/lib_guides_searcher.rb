# frozen_string_literal: true

module QuickSearch
  class LibGuidesSearcher < QuickSearch::ApplicationSearcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::LibGuidesSearchService.new(http: http).search(q)
    end

    def loaded_link
      format(Settings.LIBGUIDES.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end

    def toggleable?
      true
    end

    def toggle_threshold
      Settings.LIBGUIDES.NUM_RESULTS_SHOWN
    end
  end
end
