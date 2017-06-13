# This migration comes from blacklight (originally 20140202020202)
# -*- encoding : utf-8 -*-
class CreateBookmarks < ActiveRecord::Migration[5.0]
  def self.up
    create_table :bookmarks do |t|
      t.integer :user_id, :null=>false
      t.string :user_type
      t.string :document_id
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :bookmarks
  end
  
end
