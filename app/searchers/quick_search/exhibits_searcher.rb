# frozen_string_literal: true

module QuickSearch
  class ExhibitsSearcher < QuickSearch::ApplicationSearcher
    delegate :results, :total, to: :@response

    def search
      @response ||= ::ExhibitsSearchService.new(http: http).search(q)
    end

    def loaded_link
      format(Settings.EXHIBITS.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
