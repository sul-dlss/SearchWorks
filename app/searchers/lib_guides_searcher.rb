# frozen_string_literal: true

class LibGuidesSearcher < ApplicationSearcher
  self.search_service = ::LibGuidesSearchService

  def see_all_url_template
    Settings.libguides.query_url
  end
end
