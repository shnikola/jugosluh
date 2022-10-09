require 'cyrillizer'

class Importer

  def start(year = nil)
    DiscogsApi.new.search(year: year) do |record|
      import_release(record)
    end
  end

  def import_release(record)
    # Ignore everything after 1.10.1991 - the closure of Jugoton.
    return if record[:year].to_i > 1991
    print "Importing #{record[:id]} [#{record[:title]}]... "

    release = DiscogsRelease.find_by(id: record[:id])

    # New release
    if release.nil?
      print "New release\n".light_blue
      release = DiscogsRelease.create_from_discogs(record)
      check_pending_release(release)

    # Release still pending
    elsif release.pending? && release.changed_from_discogs?(record)
      print "Updating release\n".yellow
      release.update_from_discogs(record)
      check_pending_release(release)

    # Confirmed release that has changed
    elsif release.confirmed? && release.changed_from_discogs?(record)
      print "Updating release\n".yellow
      release.update_from_discogs(record)
      update_album(release)

    else
      print "Skipping\n"
    end
  end

  def check_pending_release(release)
    # Make sure all connected version are updated
    update_master_versions(release.discogs_master_id) if release.discogs_master_id.present?

    # Initialize potential album
    album_fields = prepare_album_fields(release)

    if duplicate_release?(release)
      release.duplicate!
      print "Detected as duplicate\n".yellow
    elsif skippable_release?(album_fields)
      release.skip!
      print "Not in Yu, skipping.\n".yellow
    elsif confirmed_release?(album_fields)
      release.confirmed!
      create_album(album_fields)
    else
      print "Not sure, leaving as pending\n".magenta
    end
  end

  def create_album(album_fields)
    unconnected_album = Album.find_by(discogs_release_id: nil, catnum: album_fields[:catnum])
    if unconnected_album
      unconnected_album.update(album_fields)
      print "Unconnected album updated! ".green + printable_album_changes(unconnected_album) + "\n"
    else
      album = Album.create(album_fields)
      print "New album confirmed! ".green + printable_album_changes(album) + "\n"
    end
  end

  def update_album(release)
    album = Album.find_by(discogs_release_id: release.id)
    album.update(prepare_album_fields(release))
    print "Updated [#{album.id}]: ".yellow + printable_album_changes(album) + "\n" if album.saved_changes?
  end

  private

  def prepare_album_fields(release)
    full_record = DiscogsApi.new.get(release.id)
    artist = full_record[:artists].map{|a| clean_artist_name(a) }.compact.join(", ")
    best_label = full_record[:labels].find{|l| Label.major?(l[:name])} || full_record[:labels].first
    best_image = full_record[:images].find{|i| i[:type] == 'primary'} || full_record[:images].first if full_record[:images]

    {
      title: full_record[:title].to_lat,
      artist: artist,
      label: Label.normalize(best_label[:name]),
      catnum: Catnum.normalize(best_label[:catno]),
      year: full_record[:year] == 0 ? nil : full_record[:year],
      info_url: full_record[:uri],
      image_url: best_image && best_image[:uri],
      discogs_release_id: release.id,
      track_count: count_tracks(full_record[:tracklist])
    }
  end

  def update_master_versions(master_id)
    version_ids = DiscogsApi.new.get_master_release_ids(master_id)
    DiscogsRelease.where(id: version_ids).update_all(discogs_master_id: master_id) if version_ids.present?
  end

  def duplicate_release?(release)
    release.discogs_master_id.present? && DiscogsRelease.where(
      status: [:confirmed, :skip],
      discogs_master_id: release.discogs_master_id,
    ).where.not(id: release.id).exists?
  end

  def skippable_release?(album_fields)
    Label.foreign_series?(album_fields[:label], album_fields[:catnum]) || album_fields[:year].to_i > 1991
  end

  def confirmed_release?(album_fields)
    Label.domestic_series?(album_fields[:label], album_fields[:catnum]) && album_fields[:year].present?
  end

  def clean_artist_name(artist)
    name = (artist[:anv].presence || artist[:name]).to_lat
    name.gsub!(/\(\d+\)/, '') # Remove Discogs (2) notations
    name.squish!
    name
  end

  def count_tracks(tracklist)
    tracks = tracklist.select{ |t| t[:type_] == "track" && t[:title].present? }
    if tracks.count == 0
      tracks = tracklist.flat_map{ |t| t[:sub_tracks] }.compact
      tracks = tracks.select{ |t| t[:type_] == "track" && t[:title].present? }
    end
    tracks.count
  end

  def printable_album_changes(album)
    album.saved_changes.map do |attr, values|
      if attr.in?(['label', 'catnum'])
        "#{attr}: #{values[0]} > #{values[1]}".red
      elsif attr.in?(['title', 'artist', 'year', 'track_count'])
        "#{attr}: #{values[0]} > #{values[1]}".yellow
      else
        attr.yellow
      end
    end.join(", ")
  end

end
