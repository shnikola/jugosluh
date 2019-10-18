class AddOriginalCatnum < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :discogs_catnum, :string
  end
end
