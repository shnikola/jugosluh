class CreateDiscogsReleases < ActiveRecord::Migration[5.2]
  def change
    create_table :discogs_releases do |t|
      t.string :title, limit: 1000
      t.string :labels, limit: 500
      t.string :catno
      t.integer :year
      t.string :cover_image
      t.string :discogs_master_id, index: true
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
