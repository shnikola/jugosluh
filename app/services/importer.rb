require 'cyrillizer'

class Importer

  def start
    imported = []
    DiscogsYu.find_each do |release|
      next if !import_release?(release)
      album = import_release(release.id)
      imported << album if album
    end

    Cleaner.new.after_import(imported.map(&:id))
  end

  def import_from_sources
    Source.confirmed.unconnected.where("catnum LIKE 'EP-%'").each do |s|
      label = "PGP RTB"
      year = s.title.match(/(\d{4})/).try(:[], 1).try(:to_i) || s.details.match(/(\19d{2})/).try(:[], 1).try(:to_i)
      title = s.title.split("-").last.titleize.strip
      album = Album.where(catnum: s.catnum).first.try(:original)
      album ||= Album.create(label: label, catnum: s.catnum, year: year, artist: s.artist.strip, title: title, in_yu: true)
      s.update(album_id: album.id)
    end
  end


  def import_release(release_id)
    full_release = DiscogsYu.find_by_id(release_id)
    print "Importing #{full_release.id} [#{full_release.title}]... " if full_release
    save_to_db(full_release) if full_release
  end

  def save_to_db(release)
    label, catnum, original_catnum = select_label_info(release.labels)

    # Check by label+catnum if we have the same non-discogs album already in db
    album = Album.non_discogs.find_by(label: label, catnum: catnum) if catnum != 'NONE'
    if album
      print "Connected to manually entered (#{album})...".light_blue
      print "Track count different ".red if album.track_count && album.track_count != count_tracks(release.tracklist)
    end

    album ||= Album.find_by(discogs_release_id: release.id)
    album ||= Album.new(catnum: catnum, label: label)

    # Overwrite old catnum only if the discogs one has changed
    if album.persisted? && album.discogs_catnum != original_catnum
      album.catnum = catnum
      print "Catnum Changed! ".red if album.catnum_changed?
    end

    album.year = release.year.to_i if release.year.to_i > 0

    album.assign_attributes(
      artist: select_artist_info(release.artists),
      title: release.title.to_lat,
      discogs_release_id: release.id,
      discogs_master_id: release.master_id,
      discogs_catnum: original_catnum,
      info_url: release.uri,
      image_url: select_image_url(release.images),
      track_count: count_tracks(release.tracklist)
    )

    if album.new_record?
      album.save
      print "New album [#{album.id}].\n".green
    else
      changes = album.changes.map{|k, v| "#{k}: #{v[0]} > #{v[1]}"}
      album.save
      print "Updated [#{album.id}] #{changes.join(', ')}\n".yellow
    end

    album
  end

  private

  def import_release?(release)
    album = Album.find_by(discogs_release_id: release.id)
    if album.nil?
      true
    elsif album.in_yu? == false
      false # Skip re-import of non-yu albums
    elsif !album.info_url.include?(release.uri)
      true # Reimport if url (artist + title) changed
    elsif album.image_url.nil? && release.thumb.present?
      true # Reimport if image is missing
    elsif album.year != release.year.to_i && release.year.to_i > 0
      true # Reimport if year has changed
    elsif album.discogs_catnum != release.catno
      true # Reimport id catnum has changed
    else
      false
    end
  end

  def select_label_info(labels)
    # In case of multiple, prefer known label
    label = labels.find{|l| Label.major?(l.name)} || labels.first
    return Label.normalize(label.name), Catnum.normalize(label.catno), label.catno
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

  def count_tracks(tracklist)
    tracks = tracklist.select{ |t| t.type_ == "track" && t.title.present? }
    if tracks.count == 0
      tracks = tracklist.flat_map{ |t| t.sub_tracks }.compact
      tracks = tracks.select{ |t| t.type_ == "track" && t.title.present? }
    end
    tracks.count
  end

end
