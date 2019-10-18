class AddTracksToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :tracks, :integer
  end
end
