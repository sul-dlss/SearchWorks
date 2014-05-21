require 'selected_databases'
class SelectedDatabasesController < ApplicationController
  include Blacklight::SolrHelper
  def index
    _, solr_documents = get_solr_response_for_field_values('id', SelectedDatabases.ids, {sort: "title_sort asc", rows: 100})
    @selected_databases = SelectedDatabases.new(solr_documents)
  end
end
