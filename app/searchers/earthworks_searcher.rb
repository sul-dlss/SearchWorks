# frozen_string_literal: true

class EarthworksSearcher < ApplicationSearcher
  self.search_service = ::EarthworksSearchService
end
