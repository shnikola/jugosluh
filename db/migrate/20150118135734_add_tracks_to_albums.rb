class AddTracksToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :tracks, :integer
  end
end
