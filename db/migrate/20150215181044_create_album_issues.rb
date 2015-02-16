class CreateAlbumIssues < ActiveRecord::Migration
  def change
    create_table :album_issues do |t|
      t.integer :album_id
      t.integer :user_id
      t.text :message
      t.timestamps
    end
  end
end
