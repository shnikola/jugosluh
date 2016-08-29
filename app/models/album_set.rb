class AlbumSet < ActiveRecord::Base

  def self.generate_weekly
    name = Time.now.beginning_of_week.strftime("%Y-%m-%d")
    return false if AlbumSet.where(name: name).exists?
    previous_album_ids = AlbumSet.pluck(:album_ids).join(";").split(";")
    album_scope = Album.of_interest.uploaded.where.not(id: previous_album_ids).random
    sps = album_scope.where(track_count: (1..2)).first(100)
    eps = album_scope.where(track_count: (3..4)).first(100)
    lps = album_scope.where("track_count > 4").first(100)
    create(name: name, album_ids: (sps + eps + lps).map(&:id).join(";"))
  end

  def albums
    Album.where(id: album_ids.split(";"))
  end
end
