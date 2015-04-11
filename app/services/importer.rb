require 'cyrillizer'

class Importer
  
  def start
    DiscogsYu.find_each do |release|
      next if Album.where(discogs_release_id: release.id).exists?

      sleep(0.5) # move to discogs yu
      
      p "Importing #{release.id} [#{release.title}]"
      full_release = DiscogsYu.find_by_id(release.id)
      save_to_db(full_release) if full_release
    end
  end
  
  def save_to_db(release)
    label_info = select_label_info(release.labels)
    catnum = Catnum.normalize(label_info.catno)
    
    # Check by label+catnum if we have the same non-discogs album already in db
    if album = Album.non_discogs.find_by(label: label_info.name, catnum: catnum)
      album.update_attributes(discogs_release_id: release.id, discogs_master_id: release.master_id, info_url: release.uri)
      return album
    end
    
    # So this is a completely new release to us
    artist = select_artist_info(release.artists)
    original_id = find_original_id(release.master_id)
    
    album = Album.create(
      label: label_info.name,
      catnum: catnum,
      year: release.year,
      artist: artist,
      title: release.title.to_lat, 
      duplicate_of_id: original_id,
      discogs_release_id: release.id,
      discogs_master_id: release.master_id,
      info_url: release.uri,
      image_url: select_image_url(release.images),
      tracks: release.tracklist.size
    )
    
    select_best_original(album) if album.duplicate_of_id?
    
    album
  end
  
  private
  
  def select_label_info(labels)
    p "Multiple labels: #{labels.map(&:name)}" if labels.size > 1
    
    known_labels = labels.select do |l| 
      ["Jugoton", "PGP RTB", "PGP RTS", "Jugodisk", "Diskos", "Diskoton", "Helidon", "Suzy", "Beograd Disk"].include?(l.name)
    end
    
    known_labels.first || labels.first
  end
  
  def select_artist_info(artists)
    artist = artists.map{|a| [a.anv.presence || a.name, a.join || ""].join(" ")}.join(" ")
    artist = artist.gsub(/\s+/, ' ').gsub(" ,", ",").strip.to_lat
  end
  
  def select_image_url(images)
    return nil if images.blank?
    image = images.detect{|i| i.type == 'primary'} || images.first
    image.uri if image
  end
  
  def find_original_id(master_id)
    return if master_id.nil?
    Album.original.where(discogs_master_id: master_id).pluck(:id).first
  end
  
  def select_best_original(album)
    # If the duplicate was out earlier than the original, choose it as an original
    original = album.original
    earlier_year = album.year != 0 && album.year < original.year
    earlier_release = album.discogs_release_id.to_s < original.discogs_release_id.to_s
    if earlier_year || earlier_release
      original.id = 0
      original.save
    
      duplicate_id = album.id
      album.id = album.duplicate_of_id
      album.duplicate_of_id = nil
      album.save
      
      original.id = duplicate_id
      original.duplicate_of_id = album.id
      original.save
    end
  end
  
end