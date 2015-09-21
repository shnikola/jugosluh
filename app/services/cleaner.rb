class Cleaner

  # ==== After import:

  def detect_yu_music
    # All after 1991 is not yu
    Album.unresolved.where("year > 1991").update_all(in_yu: false)

    # Assign originals first
    Album.unresolved.original.where("year != 0").find_each do |album|
      if yu_catnum_series?(album.label, album.catnum)
        print "+ #{album.id} #{album.full_info}\n"
        album.update_attributes(in_yu: true)
      elsif foreign_artist?(album.artist)
        print "- #{album.id} #{album.full_info}\n"
        album.update_attributes(in_yu: false)
      end
    end

    # Assign duplicates to same as originals
    Album.unresolved.where.not(duplicate_of_id: nil).find_each do |album|
      album.update_attributes(in_yu: album.original.in_yu)
    end
  end

  def list_missing_years
    # TODO
  end

  def list_duplicate_catnums
    album_map = Hash.new([])
    Album.original.where("catnum != ?", 'NONE').where("in_yu IS NULL OR in_yu = 1").find_each do |album|
      album_map[album.label + "#" + album.catnum] += [album]
    end

    album_map.select!{|_, v| v.count > 1}
    album_map.values.each do |albums|
      albums.each { |a| print "[#{a.label} #{a.catnum}] #{a.artist} - #{a.title}\n"}
    end
  end

  def select_best_original
    Album.where("duplicate_of_id IS NOT NULL").find_each do |duplicate|
      original = duplicate.original

      if better_info?(duplicate, original)
        duplicate_attrs, original_attrs = duplicate.info_attributes, original.info_attributes
        p "Switching #{original.id} - #{duplicate.id}"
        original.update_attributes(duplicate_attrs)
        duplicate.update_attributes(original_attrs)
      end
    end
  end

  # ==== After download:

  def reconnect_mismatched_sources
    downloader = Downloader.new
    Source.download_mismatched.find_each do |source|
      album = source.possible_albums.reject{|a| a.id == source.album_id}.first
      next if album.nil?
      p "New connection: #{source.title} :: #{album}"
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
        print "Found complete #{source.album}, cleaning #{source.title} (#{source.id})\n"
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

  def foreign_artist?(artist)
    return false if artist.blank? || artist =~ /Various|Unknown artist/i
    artist_albums = Album.original.where(artist: artist, in_yu: false).where("year < 1990 AND year != 0")
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
    when /Jugodisk/i
      catnum =~ /(^BDN-)|(^JDN-)|(^LPD-0)/
    end
  end

  def better_info?(duplicate, original)
    # If the duplicate was out earlier than the original
    (duplicate.year? && duplicate.year < original.year) ||
    (duplicate.year == original.year && duplicate.catnum.start_with?('L') && !original.catnum.start_with?('L'))
  end
end
