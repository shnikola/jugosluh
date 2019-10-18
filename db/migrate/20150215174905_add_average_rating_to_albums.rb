class AddAverageRatingToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :average_rating, :float
  end
end
