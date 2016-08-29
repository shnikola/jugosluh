class CreateAlbumSets < ActiveRecord::Migration
  def change
    create_table :album_sets do |t|
      t.string :name
      t.string :album_ids
      t.timestamps
    end
  end
end
