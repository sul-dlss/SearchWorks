# frozen_string_literal: true

module QuickSearch
  class EarthworksSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::EarthworksSearchService

    def see_all_url_template
      Settings.earthworks.query_url
    end
  end
end
