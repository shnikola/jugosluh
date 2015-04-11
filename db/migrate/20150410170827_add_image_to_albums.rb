class AddImageToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :image_url, :string
  end
end
