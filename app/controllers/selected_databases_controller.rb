# frozen_string_literal: true

class SelectedDatabasesController < ApplicationController
  include Blacklight::Searchable
  def index
    ids = Settings.selected_databases.keys.map(&:to_s)
    _, solr_documents = search_service.fetch(ids, { sort: "title_sort asc", rows: ids.length })

    @selected_databases = solr_documents
  end
end
