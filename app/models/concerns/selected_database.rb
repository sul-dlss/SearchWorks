# frozen_string_literal: true

module SelectedDatabase
  def selected_database_subjects
    database_config[:subjects]
  end

  def selected_database_description
    database_config[:description]
  end

  def selected_database_see_also
    database_config[:see_also]
  end

  private

  def database_config
    @database_config ||= Settings.selected_databases[id]
  end
end
