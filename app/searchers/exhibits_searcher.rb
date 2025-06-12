# frozen_string_literal: true

class ExhibitsSearcher < ApplicationSearcher
  self.search_service = ::ExhibitsSearchService

  def see_all_url_template
    Settings.exhibits.query_url
  end
end
