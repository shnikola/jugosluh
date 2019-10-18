class Album < ApplicationRecord
  has_many :user_ratings

  scope :original, -> { where(duplicate_of_id: nil) }
  scope :of_interest, -> { original.where(in_yu: true) }
  scope :non_discogs, -> { where(discogs_release_id: nil) }
  scope :uploaded, -> { where("download_url IS NOT NULL") }
  scope :with_cover, -> { where.not(image_url: nil) }

  scope :maybe_in_yu, -> { where("in_yu IS NULL OR in_yu = 1") }
  scope :unresolved, -> { where(in_yu: nil) }

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

  def full_info
    "[#{label} #{catnum}] #{artist} - #{title}"
  end

  def original
    duplicate_of_id ? Album.find(duplicate_of_id) : self
  end

  def maybe_in_yu?
    in_yu? || in_yu.nil?
  end

  def uploaded?
    download_url.present?
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

  def info_attributes
    attributes.except("id", "duplicate_of_id", "download_url", "drive_id", "average_rating", "tracklist")
  end

  def as_json(options = {})
    attributes.slice("id", "label", "catnum", "year", "artist", "title", "info_url", "image_url", "track_count", "average_rating")
  end

end
