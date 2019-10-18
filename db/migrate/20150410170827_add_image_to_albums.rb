class AddImageToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :image_url, :string
  end
end
