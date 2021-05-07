require 'selected_databases'
class SelectedDatabasesController < ApplicationController
  include Blacklight::Searchable

  def index
    _, solr_documents = search_service.fetch(SelectedDatabases.ids, { sort: "title_sort asc", rows: 100 })
    @selected_databases = SelectedDatabases.new(solr_documents)
  end
end
