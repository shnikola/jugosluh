require 'cyrillizer'

class Importer
  
  def start
    DiscogsYu.find_each do |release|
      if Album.where(discogs_release_id: release.id).exists?
        p "Importing #{release.id} [#{release.title}]"
        full_release = DiscogsYu.find_by_id(release.id)
        save_to_db(full_release) if full_release
      end
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
    
    artist = select_artist_info(release.artists)
    
    album = Album.create(
      label: label_info.name,
      catnum: catnum,
      year: release.year,
      artist: artist,
      title: release.title.to_lat, 
      duplicate_of_id: original_id,
      discogs_release_id: release.id,
      discogs_master_id: release.master_id,
      discogs_catnum: label_info.catno,
      info_url: release.uri,
      image_url: select_image_url(release.images),
      tracks: select_tracks(release.tracklist)
    )

    check_for_duplicate(album)
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
    artist = artist.gsub(/\s+/, ' ').gsub(" ,", ",").gsub(/,\s?$/, '').strip.to_lat
  end
  
  def select_image_url(images)
    return nil if images.blank?
    image = images.detect{|i| i.type == 'primary'} || images.first
    image.uri if image
  end
  
  def select_tracks(tracklist)
    tracklist.count{|t| t.type_ == "track" }
  end
  
  def check_for_duplicate(album)
    original = find_original(album)
    return if original.nil?
    
    # If original doesn't have a master_id, try re-fetching it
    if original.discogs_master_id.blank?
      original_release = DiscogsYu.find_by_id(album.discogs_release_id)
      original.update_attributes(discogs_master_id: original_release.master_id) if original_release.try(:master_id)
    end
    
    album.update_attributes(duplicate_of_id: original.id)
  end

  def find_original(album)
    # Try finding the original either by master_id or by label+catnum+title
    # This might not catch every original, but it will not catch false ones
    original = Album.original.where("id != ?", album.id).where(discogs_master_id: album.discogs_master_id).first if album.discogs_master_id
    original ||= Album.original.where("id != ?", album.id).where("catnum != 'NONE'").where(label: album.label, catnum: album.catnum, title: album.title).first
  end
      
end