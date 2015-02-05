class Album < ActiveRecord::Base
  has_many :user_ratings
  
  scope :original, -> { where(duplicate_of_id: nil) }
  scope :of_interest, -> { original.where(in_yu: true) }
  scope :downloaded, -> { where("download_url IS NOT NULL") }
  
  def self.random
    random_func = Rails.env.production? ? "RANDOM()" : "RAND()"
    order(random_func).first
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
  
  def self.update_or_create_from_discogs(release)
    label = choose_label(release)
    catnum = label.catno.strip.gsub(/[\s-]+/, "-").upcase
    if album = find_by(label: label.name, catnum: catnum)
      album.update_attributes(discogs_release_id: release.id, discogs_master_id: release.master_id, info_url: release.uri)
      album
    else
      artist = release.artists.map{|a| [a.anv.presence || a.name, a.join || ""].join(" ")}.join(" ")
      artist = artist.gsub(/\s+/, ' ').gsub(" ,", ",").strip
      original_id = find_origin(release.master_id).try(:id)
      create(label: label.name, catnum: catnum, year: release.year, artist: artist, title: release.title, 
               duplicate_of_id: original_id, discogs_release_id: release.id, discogs_master_id: release.master_id,
               info_url: release.uri, tracks: release.tracklist.size)
    end
  end
  
  def self.find_origin(master_id)
    return if master_id.nil?
    where(duplicate_of_id: nil, discogs_master_id: master_id).first
  end
  
  def self.choose_label(release)
    label = release.labels.find{|l| ["Jugoton", "PGP RTB", "PGP RTS", "Jugodisk", "Diskos", "Diskoton", "Helidon", "Suzy"].include?(l.name)}
    if label.nil? && release.labels.length > 1
      puts "Multiple labels: #{release.id} - #{release.labels.map(&:name)} - #{release.labels.map(&:catno)}\n"
    end
    label || release.labels.first
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
  
end