class AddOriginalCatnum < ActiveRecord::Migration
  def change
    add_column :albums, :discogs_catnum, :string
  end
end
