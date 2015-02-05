class AddTimestampsToUserRatings < ActiveRecord::Migration

  def change
    change_table :user_ratings do |t|
      t.timestamps
    end
  end
  
end
