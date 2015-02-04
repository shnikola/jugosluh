class CreateSource < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :artist
      t.string :title
      t.string :catnum
      t.text :details
      t.string :download_url
      t.boolean :from_yu
      t.boolean :downloaded, default: 0
      t.integer :album_id
      t.timestamps
    end
  end
end
