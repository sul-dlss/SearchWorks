# frozen_string_literal: true

module QuickSearch
  class ArchivesSearcher < QuickSearch::ApplicationSearcher
    self.search_service = ::ArchivesSearchService

    def see_all_url_template
      Settings.archives.query_url
    end
  end
end
