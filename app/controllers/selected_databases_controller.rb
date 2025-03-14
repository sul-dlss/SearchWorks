# frozen_string_literal: true

class SelectedDatabasesController < ApplicationController
  include Blacklight::Searchable
  def index
    ids = Settings.selected_databases.keys.map(&:to_s)
    @selected_databases = search_service.fetch(ids, { sort: "title_sort asc", rows: ids.length })
  end
end
