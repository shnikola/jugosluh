class UserListAlbum < ApplicationRecord
  belongs_to :user_list, counter_cache: true
  belongs_to :album
end
