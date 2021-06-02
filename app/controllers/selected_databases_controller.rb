class SelectedDatabasesController < ApplicationController
  include Blacklight::SearchHelper
  def index
    ids = Settings.selected_databases.keys.map(&:to_s)
    _, solr_documents = fetch(ids, { sort: "title_sort asc", rows: ids.length })

    @selected_databases = solr_documents
  end
end
