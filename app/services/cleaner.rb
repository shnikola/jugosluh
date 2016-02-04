class Cleaner

  # ==== After import:

  def after_import(album_ids)
    return if album_ids.blank?
    detect_duplicates(album_ids)
    detect_yu_music(album_ids)
    connect_unmatched_sources(album_ids: album_ids)
  end

  def detect_yu_music(album_ids = nil)
    print "\nDetecting confirmed YU music...\n".on_blue
    albums = album_ids ? Album.where(id: album_ids) : Album.all

    # All after 1991 is not yu
    resolved = albums.unresolved.where("year > 1991").update_all(in_yu: false)
    print "Detected #{resolved} articles after 1991.\n".red if resolved > 0

    # Assign originals first
    albums.unresolved.original.where("year IS NOT NULL").find_each do |album|
      if yu_catnum_series?(album.label, album.catnum)
        print "+ #{album.id} #{album.full_info}\n".green
        album.update_attributes(in_yu: true)
      elsif foreign_artist?(album.artist)
        print "- #{album.id} #{album.full_info}\n".red
        album.update_attributes(in_yu: false)
      end
    end

    # Assign duplicates to same as originals
    albums.unresolved.where.not(duplicate_of_id: nil).find_each do |album|
      album.update_attributes(in_yu: album.original.in_yu)
    end
  end

  def detect_duplicates(album_ids = nil)
    print "\nDetecting duplicates...\n".on_blue
    albums = album_ids ? Album.where(id: album_ids) : Album.all

    albums.original.order("id DESC").each do |album|
      original = find_original(album)
      next if original.nil?
      album.update_attributes(duplicate_of_id: original.id)
      print "Duplicate #{album} (#{album.id}) of #{original} (#{original.id})\n".green
      print "Already uploaded!\n".red if album.download_url?

      if better_info?(album, original)
        print "Better info in duplicate, switching.\n".blue
        duplicate_attrs, original_attrs = album.info_attributes, original.info_attributes
        original.update_attributes(duplicate_attrs)
        album.update_attributes(original_attrs)
      end
    end
  end

  def connect_unmatched_sources(album_ids: nil, source_ids: nil)
    print "\nConnecting unmatched sources...\n".on_blue
    sources = source_ids ? Source.where(id: source_ids) : Source.all

    sources.confirmed.unconnected.find_each do |source|
      albums = possible_matches(source)
      albums.select!{ |a| album_ids.include?(a.id) } if album_ids.present?
      next if albums.empty?

      print "#{source.title} [#{source.id}]\n"
      print "Multiple: #{albums.map(&:to_s).join(', ')}\n".light_blue if albums.count > 1

      album = albums.first
      if source.catnum? && source.catnum == album.catnum
        print "#{album} (#{album.year}) [#{album.id}]\n".green
      else
        print "#{album} (#{album.year}) [#{album.id}]\n".yellow
      end

      source.update_attributes(album_id: album.id)
    end
  end

  # ==== After collecting

  def after_collecting(source_ids)
    return if source_ids.blank?
    connect_unmatched_sources(source_ids: source_ids)
  end


  def find_missing_years
    # Search discogs updates
    Album.original.maybe_in_yu.where(year: nil).find_each do |album|
      next if album.discogs_release_id.blank?
      release = DiscogsYu.find_by_id(album.discogs_release_id)
      if release.year.to_i > 0
        album.update(year: release.year)
        print "#{album} [#{album.year}] (#{album.id})\n".green
      end
    end

    # Search from sources
    Source.downloaded.includes(:album).where(albums: {year: nil}).find_each do |source|
      next if source.album.year? # We might have updated it from a previous source
      year = source.title.match(/\b(19\d\d)\b/).try(:[], 1)
      if year
        print "#{source.album} [#{source.album.year}] (#{source.album.id})\n".yellow
        print "#{source.title} [#{year}] (#{source.id})\n\n".green
        source.album.update(year: year)
      end
    end
  end

  # ==== After download:

  # WARNING: this one produced a lot of manual work, try to make it smarter
  # it found a lot of undetected duplicates though
  def recheck_downloaded_sources(source_ids = [])
    sources = source_ids ? Source.where(id: source_ids) : Source.all

    sources.downloaded.joins(:album).where("sources.catnum IS NOT NULL AND sources.catnum != albums.catnum").each do |source|
      new_album = possible_matches(source).first
      if new_album.nil?
        # Ignore for now, although these should be recheked too
      elsif new_album != source.album
        print "#{source.title} [#{source.id}] [#{source.catnum}]\n".yellow
        print "#{source.album} (#{source.album.year}) [#{source.album.id}] [#{source.album.catnum}]\n".yellow
        print "#{new_album} (#{new_album.year}) [#{new_album.id}] [#{new_album.catnum}]\n\n".green
        #source.update(status: 1, album_id: new_album.id)
      end
    end
  end

  def reconnect_mismatched_sources
    downloader = Downloader.new
    Source.download_mismatched.find_each do |source|
      albums = possible_matches(source).reject{|a| a.id == source.album_id}
      next if albums.empty?

      print "#{source.title} [#{source.id}]\n"
      print "Multiple: #{albums.map(&:to_s).join(', ')}\n".light_blue if albums.count > 1

      album = albums.first
      if source.catnum? && source.catnum == album.catnum
        print "#{album} (#{album.year}) [#{album.id}]\n".green
      else
        # next
        print "#{album} (#{album.year}) [#{album.id}]\n".yellow
      end

      current_folder = "#{Rails.root}/tmp/downloads/#{downloader.folder_name(source)}"
      source.update_attributes(album_id: album.id)
      downloader.check_downloaded(source, current_folder)
    end
  end

  def clean_incomplete_sources
    downloader = Downloader.new
    Source.incomplete.find_each do |source|
      current_folder = "#{Rails.root}/tmp/downloads/#{downloader.folder_name(source)}"
      if Source.downloaded.where(album_id: source.album_id).exists?
        print "Found complete #{source.album}, cleaning #{source.title} (#{source.id})\n".green
        source.downloaded!
        `rm -r #{current_folder}`
      end
    end
  end

  def browse_mismatched_sources
    downloader = Downloader.new
    Source.download_mismatched.find_each do |source|
      print "#{source.title} :: #{source.album} (#{source.album.year})\n"
      print "  Source ID: #{source.id}\n"
      print "  Album ID: #{source.album_id}\n"
      print "  Tracks: #{source.album.tracks}\n"
      print "  URL: #{source.album.info_url}\n"

      current_folder = "#{Rails.root}/tmp/downloads/#{downloader.folder_name(source)}"
      `open #{current_folder}`
      command = gets.strip
      case command
      when /^a/
        album_id = command.split(":").last if command.include?(":")
        source.update_attributes(album_id: album_id) if album_id
        downloader.check_downloaded(source, current_folder)
      when /^c/
        _, label, catnum, artist, year, title, tracks = command.split(":")
        album = Album.create(label: label, catnum: catnum, year: year, artist: artist, title: title, tracks: tracks, in_yu: 1)
        source.update_attributes(album_id: album.id)
        downloader.check_downloaded(source, current_folder)
      when /^i/
        source.incomplete!
      when /^n/
        source.skipped!
        source.update_attributes(album_id: nil)
        `rm -r #{current_folder}`
      when /^r/
        source.confirmed!
        source.update_attributes(album_id: nil)
        `rm -r #{current_folder}`
      end
    end
  end

  private

  def possible_matches(source)
    possible = []

    # Search by catnum
    if source.catnum.present?
      album = Album.find_by(catnum: Catnum.normalize(source.catnum)).try(:original)
      possible << album if album
      # Let's skip searching other searches if catnum is provided, found or not.
      # This reduces the number of wrong matches
      return possible
    end

    # Search by name
    if source.title.present?
      title = source.title.downcase
      title = title.gsub(/19\d\d/, '').gsub(/[–-]\s+\d\s+[–-]/, '') # years confuse me
      title = title.gsub(/\[.+\]/, '') # angle bracket content too
      title = title.gsub(/[^[:word:]\s]/, '') # Remove all interpunction (and ugly invisibles)

      releases = []
      releases += DiscogsYu.search_by_name(title, 1)
      releases += DiscogsYu.search_by_name(title.gsub("dj", "đ"), 1) if title.include?('dj')

      releases.each do |release|
        album = Album.find_by(discogs_release_id: release.id).try(:original)
        album ||= Importer.new.import_release(release)
        possible << album if album.in_yu?
      end
    end

    possible.uniq
  end

  def foreign_artist?(artist)
    return false if artist.blank? || artist =~ /Various|Unknown artist/i
    artist_albums = Album.original.where(artist: artist, in_yu: false).where("year < 1990")
    artist_albums.count > 2
  end

  def yu_catnum_series?(label, catnum)
    case label
    when /Jugoton/i
      catnum =~ /(^CAY-)|(^EPY-)|(^F-)|(^LPY)|(^LSY-6)|(^MCY-)|(^SY-)/
    when /PGP RTB/i
      catnum =~ /(^111)|(^112)|(^15)|(^20)|(^21)|(^23)|(^31)|(^40)|(^41)|(^50)|(^51)|(^80)|(^EP-1)|(^EP-50)|(^EP-6)|(^LP-1)|(^LP-6)|(^NK-)|(^S-1)|(^S-51)|(^S-52)|(^S-6)|(^SF-)/
    when /Diskos/i
      catnum =~ /(^EDK-3)|(^EDK-5)|(^LPD-)|(^MDK-)|(^NDK-1)|(^NDK-2)|(^NDK-4)|(^NDK-5)/
    when /Beograd Disk/i
      catnum =~ /(^EBK-)|(^EVK-)|(^K-)|(^LPD-)|(^SBK-0)|(^SVK-1)/
    when /Diskoton/i
      true
    when /Suzy/i
      catnum =~ /(^KS)|(^LP-)|(^SP-)/
    when /RTV Ljubljana/i
      catnum =~ /(^KD-)|(^LD-)|(^SD-)/
    when /Jugodisk/i
      catnum =~ /(^BDN-)|(^JDN-)|(^LPD-0)/
    end
  end

  def find_original(album)
    return if album.discogs_master_id.blank?
    original = Album.original.where("id != ?", album.id).order("id").find_by(discogs_master_id: album.discogs_master_id)
    return original if original
    version_ids = DiscogsYu.find_release_version_ids(album.discogs_master_id)
    Album.where(discogs_release_id: version_ids).update_all(discogs_master_id: album.discogs_master_id)
    original = Album.original.where("id != ?", album.id).order("id").find_by(discogs_master_id: album.discogs_master_id)
    return original
  end

  def better_info?(duplicate, original)
    if duplicate.label != original.label
      return true if Label.major?(duplicate.label) && !Label.major?(original.label)
      return false if !Label.major?(duplicate.label) && Label.major?(original.label)
    end

    if duplicate.year?
      return true if original.year.nil? || duplicate.year < original.year
    end

    return false
  end
end
