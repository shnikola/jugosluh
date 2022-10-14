class Album < ApplicationRecord
  belongs_to :discogs_release, optional: true
  has_many :user_ratings

  scope :uploaded, -> { where("download_url IS NOT NULL") }
  scope :with_cover, -> { where.not(image_url: nil) }

  def self.available(user)
    if user&.upload_access?
      where("download_url IS NOT NULL OR spotify_id IS NOT NULL")
    else
      where("spotify_id IS NOT NULL")
    end
  end

  def self.random
    order("RAND()")
  end

  def self.search(query)
    if query.present?
      where(["artist", "title", "catnum"].map {|c| "#{c} LIKE :query"}.join(" OR "), query: "%#{query.strip}%")
    else
      all
    end
  end

  def self.from_decade(decade)
    year_range = (1900 + decade.to_i)..(1909 + decade.to_i)
    where(year: year_range)
  end

  def to_s
    "#{artist} - #{title}"
  end

  def uploaded?
    download_url.present?
  end

  def spotify_url
   "https://open.spotify.com/album/#{spotify_id}" if spotify_id.present?
  end

  def rated_by?(user_id)
    user_ratings.any?{|ur| ur.user_id == user_id}
  end

  def tracks
    return [] if tracklist.blank?
    tracklist.split("\n").each_with_object([]) do |track, list|
      id, title = track.split(";", 2)
      list.push(title: title, url: "https://drive.google.com/uc?id=#{id}")
    end
  end

  def calculate_average_rating
    self.average_rating = 1.0 * user_ratings.sum("rating") / user_ratings.count if user_ratings.present?
    save
  end

  def as_json(options = {})
    attributes.slice("id", "label", "catnum", "year", "artist", "title", "info_url", "image_url", "track_count", "average_rating")
  end

end
