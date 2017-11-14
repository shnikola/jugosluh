class UpdateAlbumSets < ActiveRecord::Migration
  def change
    add_column :album_sets, :intro, :text
    add_column :album_sets, :albums_json, :text
  end
end
