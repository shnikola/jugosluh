class AlbumIssue < ApplicationRecord
  belongs_to :user
  belongs_to :album
end
