class CreateUserRatings < ActiveRecord::Migration
  def change
    create_table :user_ratings do |t|
      t.integer :user_id
      t.integer :album_id
      t.integer :rating
      t.text :comment
    end
    
    add_index :user_ratings, :user_id
    add_index :user_ratings, :album_id
  end
end
