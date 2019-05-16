# This migration comes from quick_search (originally 20161201142811)
class ChangeEventColumns < ActiveRecord::Migration[5.0]
  def change
    change_table :events do |t|
      t.rename :action, :item
      t.rename :label, :query
    end

    add_column :events, :action, :string
    add_reference :events, :session, foreign_key: true, type: :bigint
  end
end
