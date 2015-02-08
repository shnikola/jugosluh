class User < ActiveRecord::Base
  has_many :user_ratings
  
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  #devise :registerable
  
  def to_s
    name
  end
  
  def rated_album?(album)
    user_ratings.where(album_id: album.id).exists?
  end
  
end
