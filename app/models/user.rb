class User < ActiveRecord::Base
  has_many :user_ratings
  
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  #devise :registerable
  
  def to_s
    name
  end
  
  def rated_album?(album)
    user_rating_ids.include?(album.id)
  end
  
end
