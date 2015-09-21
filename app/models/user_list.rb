class UserList < ActiveRecord::Base
  belongs_to :user
  has_many :user_list_albums
  has_many :albums, through: :user_list_albums
end