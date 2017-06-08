require 'selected_databases'
class SelectedDatabasesController < ApplicationController
  include Blacklight::SearchHelper
  def index
    _, solr_documents = get_solr_response_for_document_ids(SelectedDatabases.ids, {sort: "title_sort asc", rows: 100})
    @selected_databases = SelectedDatabases.new(solr_documents)
  end
end
