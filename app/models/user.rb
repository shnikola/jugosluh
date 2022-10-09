class User < ApplicationRecord
  has_many :user_ratings
  has_many :album_issues
  has_many :user_lists

  devise :database_authenticatable, :rememberable, :trackable, :validatable
  devise :registerable if Rails.env.development?

  def to_s
    name
  end

  def stats
    {
      found: Album.count,
      uploaded: Album.uploaded.count,
      listened: user_ratings.count,
    }
  end

end
