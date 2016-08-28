class AlbumTracks

  def self.fetch(album)
    return [] if album.tracklist.blank?
    album.tracklist.split("\n").each_with_object([]) do |track, list|
      id, title = track.split(";", 2)
      list.push(title: title.sub(/\.mp3$/i, ''), url: "https://drive.google.com/uc?id=#{id}")
    end
  end
end
