class AddAverageRatingToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :average_rating, :float
  end
end
