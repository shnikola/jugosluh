class UserListAlbum < ActiveRecord::Base
  belongs_to :user_list, counter_cache: true
  belongs_to :album
end
