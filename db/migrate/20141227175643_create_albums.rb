class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :label
      t.string :catnum
      t.integer :year
      t.string :artist, limit: 500
      t.string :title, limit: 500
      t.string :duplicate_of_id
      t.string :discogs_release_id
      t.string :discogs_master_id
      t.string :info_url, limit: 700
      t.string :download_url
      t.boolean :in_yu
      t.boolean :confirmed, default: false
    end
    
    add_index :albums, :catnum
    add_index :albums, :discogs_release_id
  end
end
