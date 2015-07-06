class Album < ActiveRecord::Base
  has_many :user_ratings
  
  scope :original, -> { where(duplicate_of_id: nil) }
  scope :of_interest, -> { original.where(in_yu: true) }
  scope :non_discogs, -> { where(discogs_release_id: nil) }
  scope :uploaded, -> { where("download_url IS NOT NULL") }
  
  def self.random
    order("RAND()").first
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
  
  def self.find_original_by_catnum(catnum)
    find_by_catnum(Catnum.normalize(catnum)).try(:original)
  end
  
  def self.find_original_by_title(title)
    # TODO: search for non-discogs albums too
    title = title.downcase
    title = title.gsub(/19\d\d/, '').gsub(/\-\s?\d\s?\-/, '') # years confuse me
    title_dj = title.gsub("dj", "đ")
  
    release = DiscogsYu.find_by_name(title) || DiscogsYu.find_by_name(title_dj)
    find_by_discogs_release_id(release.id).try(:original) if release
  end
  
  def to_s
    "#{artist} - #{title}"
  end
  
  def folder_name
    "[#{label} #{catnum}] #{artist} - #{title}"
  end

  def original
    duplicate_of_id ? Album.find(duplicate_of_id) : self
  end
  
  def uploaded?
    download_url.present?
  end
  
  def calculate_average_rating
    self.average_rating = 1.0 * user_ratings.sum("rating") / user_ratings.count if user_ratings.present?
    save
  end
  
  def info_attributes
    attributes.slice("label", "catnum", "year", "artist", "title", "discogs_release_id", "discogs_master_id", "info_url", "image_url", "tracks")
  end
  
end