class Cleaner

  # ==== After import:

  def after_import(album_ids)
    return if album_ids.blank?
    detect_duplicates(album_ids)
    detect_yu_music(album_ids)
    connect_unmatched_sources(album_ids: album_ids)
  end

  def detect_duplicates(album_ids = nil)
    print "\nDetecting duplicates...\n".on_blue
    albums = album_ids ? Album.where(id: album_ids) : Album.all

    albums.original.order("id DESC").each do |album|
      original = find_original(album)
      next if original.nil?
      print "Duplicate #{album}, #{album.year} (#{album.id}) of #{original}, #{original.year} (#{original.id})\n".green
      if album.download_url?
        print "Already uploaded, not changing!\n".red
        next
      end

      album.update_attributes(duplicate_of_id: original.id)
      Source.where(album_id: album.id).update_all(album_id: original.id)
    end
  end

  def detect_yu_music(album_ids = nil)
    print "\nDetecting confirmed YU music...\n".on_blue
    albums = album_ids ? Album.unresolved.where(id: album_ids) : Album.unresolved

    # All after 1991 is not yu
    resolved = albums.where("year > 1991").update_all(in_yu: false)
    print "Detected #{resolved} articles after 1991.\n".red if resolved > 0

    # Assign originals first
    albums.original.find_each do |album|
      if Label.domestic?(album.label, album.catnum) && album.year?
        print "+ #{album.id} #{album.full_info}\n".green
        album.update_attributes(in_yu: true)
      elsif Label.foreign?(album.label, album.catnum)
        print "- #{album.id} #{album.full_info}\n".red
        album.update_attributes(in_yu: false)
      end
    end

    # Assign duplicates to same as originals
    albums.where.not(duplicate_of_id: nil).find_each do |album|
      album.update_attributes(in_yu: album.original.in_yu)
    end
  end

  def connect_unmatched_sources(album_ids: nil, source_ids: nil)
    print "\nConnecting unmatched sources...\n".on_blue
    sources = source_ids ? Source.where(id: source_ids) : Source.all
    sources = sources.where(catnum: Album.where(id: album_ids).pluck(:catnum).compact) if album_ids.present?

    sources.confirmed.unconnected.find_each do |source|
      albums = possible_matches(source)
      next if albums.empty?

      print "#{source.title} [#{source.id}]\n"
      print "Multiple: #{albums.map(&:to_s).join(', ')}\n".light_blue if albums.count > 1

      album = albums.first

      print "#{album} (#{album.year}) [#{album.id}]".colorize(source.catnum == album.catnum ? :green : :yellow)
      print " Maybe not in YU".red if album.in_yu.nil?
      print "\n\n"

      source.update_attributes(album_id: album.id)
    end
  end

  # ==== After collecting

  def after_collecting(source_ids)
    return if source_ids.blank?
    connect_unmatched_sources(source_ids: source_ids)
  end

  # ==== After download:

  def after_download(album_ids)
    return if album_ids.blank?
    clean_incomplete_sources(album_ids)
    find_missing_years(album_ids)
  end

  def clean_incomplete_sources(album_ids = nil)
    print "\nCleaning incomplete sources...\n".on_blue
    sources = album_ids ? Source.where(album_id: album_ids) : Source.all
    downloader = Downloader.new
    sources.download_incomplete.find_each do |source|
      current_folder = "#{Rails.root}/tmp/downloads/#{downloader.folder_name(source)}"
      if Source.downloaded.where(album_id: source.album_id).exists?
        print "Found complete #{source.album}, cleaning #{source.title} (#{source.id})\n".green
        source.downloaded!
        `rm -r #{current_folder}`
      end
    end
  end

  def find_missing_years(album_ids = nil)
    print "\nSearching for missing years...\n".on_blue
    sources = album_ids ? Source.where(album_id: album_ids) : Source.all

    # Search from sources
    sources.downloaded.joins(:album).where(albums: {year: nil}).find_each do |source|
      next if source.album.year? # We might have updated it from a previous source
      if source.year
        print "#{source.album} (#{source.album.id})\n".yellow
        print "#{source.title} [#{year}] (#{source.id})\n\n".green
        source.album.update(year: year)
      end
    end
  end

  # WARNING: this one produced a lot of manual work, try to make it smarter
  # it found a lot of undetected duplicates though
  def recheck_downloaded_sources(source_ids = nil)
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

  def reconnect_mismatched_sources(source_ids: nil)
    downloader = Downloader.new
    sources = source_ids ? Source.where(id: source_ids) : Source.all
    sources.download_mismatched.find_each do |source|
      folder = "#{downloader.download_path}/#{downloader.folder_name(source)}"
      albums = possible_matches(source).reject{|a| a.id == source.album_id}
      album = albums.find {|a| downloader.track_count_matches?(a, folder)}
      if album
        color = Source.downloaded.exists?(album_id: album.id) ? :yellow : :green
        print "#{source.title} [#{source.id}]\n"
        print "#{album} (#{album.year}) [#{album.id}]\n\n".colorize(color)
        source.update_attributes(album_id: album.id)
        downloader.check_downloaded(source, folder)
      end
    end
  end

  def clean_nonyu_sources
    Source.includes(:album).where("status >= 0").where(albums: {in_yu: false}).each do |source|
      #dir = "#{Rails.root}/tmp/downloads/#{Downloader.new.folder_name(source)}"
      #FileUtils.rm_r(dir) if File.directory?(dir)
      #source.skipped!
      print "#{source.title} [#{source.id}]\n"
      print "#{source.album} (#{source.album.year}) [#{source.album.id}]\n\n".green
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
      title = title.gsub(/\(.+\)/, '').gsub(/\[.+\]/, '') # all bracket content too
      title = title.gsub(/\bi\b/i, '') # "i" is sometimes "&", let's just remove it
      title = title.gsub(/razni\s+izvo\p{L}+/i, '') # razni izvodjaci
      title = title.gsub(/[^[:word:]\s]/, ' ') # Remove all interpunction (and ugly invisibles)

      releases = []
      releases += DiscogsYu.search_by_name(title, 1)
      releases += DiscogsYu.search_by_name(title.gsub("dj", "đ"), 1) if title.include?('dj')

      releases.each do |release|
        album = Album.find_by(discogs_release_id: release.id).try(:original)
        album ||= Importer.new.import_release(release.id)
        possible << album if album.maybe_in_yu?
      end
    end

    possible.uniq
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

end
