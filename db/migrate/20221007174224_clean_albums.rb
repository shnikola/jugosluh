class CleanAlbums < ActiveRecord::Migration[5.2]
  def change
    change_column :albums, :discogs_release_id, :integer
    remove_column :albums, :discogs_master_id
    remove_column :albums, :duplicate_of_id
    remove_column :albums, :in_yu
    remove_column :albums, :discogs_catnum
    add_column :albums, :spotify_id, :string
  end
end
