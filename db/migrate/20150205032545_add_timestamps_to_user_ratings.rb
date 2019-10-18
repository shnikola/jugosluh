class AddTimestampsToUserRatings < ActiveRecord::Migration[5.2]

  def change
    change_table :user_ratings do |t|
      t.timestamps
    end
  end
  
end
