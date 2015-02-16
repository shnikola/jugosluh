class Album < ActiveRecord::Base
  has_many :user_ratings
  
  scope :original, -> { where(duplicate_of_id: nil) }
  scope :of_interest, -> { original.where(in_yu: true) }
  scope :non_discogs, -> { where(discogs_release_id: nil) }
  scope :downloaded, -> { where("download_url IS NOT NULL") }
  
  def self.random
    random_func = Rails.env.production? ? "RANDOM()" : "RAND()"
    order(random_func).first
  end
  
  def self.search(query)
    if query.present?
      like_func = Rails.env.production? ? "ILIKE" : "LIKE"
      where(["artist", "title", "catnum"].map {|c| "#{c} #{like_func} :query"}.join(" OR "), query: "%#{query.strip}%")
    else
      all
    end
  end
    
  def self.from_decade(decade)
    year_range = (1900 + decade.to_i)..(1909 + decade.to_i) 
    where(year: year_range)
  end
  
  def self.find_original_by_catnum(catnum)
    find_by_catnum(catnum.strip.gsub(/[\s-]+/, "-").upcase).try(:original)
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
  
end