class UserList < ApplicationRecord
  belongs_to :user
  has_many :user_list_albums
  has_many :albums, through: :user_list_albums

  def to_s
    name
  end

end
