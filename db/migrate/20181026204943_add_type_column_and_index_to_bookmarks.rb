class AddTypeColumnAndIndexToBookmarks < ActiveRecord::Migration[5.2]
  def change
    add_column :bookmarks, :record_type, :string, default: 'catalog'
    add_index :bookmarks, :record_type
  end
end
