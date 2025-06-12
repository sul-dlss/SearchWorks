# frozen_string_literal: true

class EarthworksSearcher < ApplicationSearcher
  self.search_service = ::EarthworksSearchService

  def see_all_url_template
    Settings.earthworks.query_url
  end
end
