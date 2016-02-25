require 'cyrillizer'

class Importer

  def start
    imported = []
    DiscogsYu.find_each do |release|
      next if latest_version_imported?(release)
      album = import_release(release)
      imported << album if album
    end

    Cleaner.new.after_import(imported.map(&:id))
  end

  require "open-uri"
  def import_from_ezop
    imported = []

    # get pages count
    domain = "http://ezop-antikvarijat.hr"
    noko = Nokogiri::HTML(open("#{domain}/glazba.php?catID=4&subcatID=55", "Cookie" => "record_num=1"))
    total_albums = noko.css("#stranica a")[-2].text.to_i
    pages = (total_albums/500).ceil

    (1..pages).each do |i|
      url = "#{domain}/glazba.php?catID=4&subcatID=55&page=#{i}"
      noko = Nokogiri::HTML(open(url, "Cookie" => "record_num=500"))
      noko.css("#itsthetable tbody tr").each do |row|
        fields = row.css("td")
        info_url = "#{domain}/#{fields[1].css('a').first["href"]}"
        title = fields[1].css("a").text.strip
        artist = fields[1].css("span  > text()").text.strip
        year = fields[5].text.to_i if fields[5].text.to_i > 1900
        label = Label.normalize(fields[6].text)
        catnum = Catnum.normalize(fields[7].text.gsub("stereo", "")) if fields[7].text.present?
        if catnum.present? && Label.major?(label) && !Album.exists?(catnum: catnum) && Source.exists?(catnum: catnum)
          album = Album.create(label: label, catnum: catnum, year: year, artist: artist, title: title, info_url: info_url)
          imported << album
          print "#{album} #{album.catnum}\n".green
        end
      end
    end

    Cleaner.new.after_import(imported.map(&:id))
  end

  def import_release(release)
    print "Importing #{release.id} [#{release.title}]... "
    full_release = DiscogsYu.find_by_id(release.id)
    save_to_db(full_release) if full_release
  end

  def save_to_db(release)
    label, catnum = select_label_info(release.labels)

    # Check by label+catnum if we have the same non-discogs album already in db
    album = Album.non_discogs.find_by(label: label, catnum: catnum)
    print "Connected to manually entered (#{album})...".light_blue if album

    album ||= Album.find_by(discogs_release_id: release.id)
    album ||= Album.new

    album.assign_attributes(
      label: label,
      artist: select_artist_info(release.artists),
      title: release.title.to_lat,
      discogs_release_id: release.id,
      discogs_master_id: release.master_id,
      discogs_catnum: catnum,
      info_url: release.uri,
      image_url: select_image_url(release.images),
      tracks: select_tracks(release.tracklist)
    )

    album.catnum ||= catnum # Don't overwrite catnum
    album.year = release.year.to_i if release.year.to_i > 0

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

  def latest_version_imported?(release)
    # Skip re-import of non-yu albums
    return true if Album.where(discogs_release_id: release.id, in_yu: false).exists?
    # Skip full release import if year or url (artist + title) haven't changed
    version = Album.where(discogs_release_id: release.id).where("info_url LIKE ?", "%#{release.uri}%")
    version = version.where(year: release.year) if release.year.to_i > 0
    version.exists?
  end

  def select_label_info(labels)
    # In case of multiple, prefer known label
    label = labels.find{|l| Label.major?(l.name)} || labels.first
    return Label.normalize(label.name), Catnum.normalize(label.catno)
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
    tracks = tracklist.select{ |t| t.type_ == "track" && t.title.present? }
    tracks = tracklist.flat_map{ |t| t.sub_tracks.select{ |s| s.type_ == "track" && s.title.present? } } if tracks.count == 0
    tracks.count
  end

end
