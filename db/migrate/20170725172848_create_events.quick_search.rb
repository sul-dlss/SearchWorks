# This migration comes from quick_search (originally 20140130202859)
class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :category
      t.string :action
      t.string :label

      t.timestamps
    end
  end
end
