# frozen_string_literal: true

class LibraryWebsiteApiSearcher < ApplicationSearcher
  self.search_service = ::LibraryWebsiteApiSearchService

  def see_all_url_template
    Settings.library_website.query_url
  end
end
