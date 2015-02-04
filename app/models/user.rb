class User < ActiveRecord::Base
  has_many :user_ratings
  
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  devise :registerable
  
end
