# frozen_string_literal: true

module QuickSearch
  class EarthworksSearcher < QuickSearch::ApplicationSearcher
    delegate :results, :total, :facets, to: :search

    def search
      @search ||= ::EarthworksSearchService.new(http: http).search(q)
    end

    def loaded_link
      format(Settings.EARTHWORKS.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
