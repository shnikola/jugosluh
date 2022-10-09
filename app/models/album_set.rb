class AlbumSet < ApplicationRecord

  def albums
    JSON.parse(albums_json).map{|k, v| [Album.find(k), v]}
  end

end
