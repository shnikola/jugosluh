class UserRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :album
  
  def as_json(options = {})
    attributes.slice("user_id", "album_id", "rating", "comment", "created_at")
  end
end
