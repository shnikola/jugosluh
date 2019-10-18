class AddTracksToAlbum < ActiveRecord::Migration[5.2]
  def change
    rename_column :albums, :tracks, :track_count
    add_column :albums, :tracklist, :text
  end
end
