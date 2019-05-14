# This migration comes from quick_search (originally 20161201143901)
class AddSessionIdToSearches < ActiveRecord::Migration[5.2]
  def change
    add_reference :searches, :session, foreign_key: true
  end
end
