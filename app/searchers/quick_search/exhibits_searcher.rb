# frozen_string_literal: true

module QuickSearch
  class ExhibitsSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::ExhibitsSearchService.new.search(q)
    end

    def loaded_link
      format(Settings.EXHIBITS.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end

    def toggleable?
      true
    end

    def toggle_threshold
      Settings.EXHIBITS.NUM_RESULTS_SHOWN
    end
  end
end
