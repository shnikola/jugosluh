class CreateLists < ActiveRecord::Migration
  def change
    create_table :user_lists do |t|
      t.integer :user_id
      t.string :name
      t.integer :user_list_albums_count
      t.timestamps
    end
    
    create_table :user_list_albums do |t|
      t.integer :user_list_id
      t.integer :album_id
      t.text :note
      t.timestamps
    end
  end
end
