class Uploader

  CURRENT_DRIVE_ID = 19

  def start(*ids)
    ids = Source.downloaded.pluck(:album_id) if ids.empty?
    Album.where(id: ids).where("year IS NOT NULL").where("track_count IS NOT NULL").order("year").each do |album|
      next if album.uploaded? || !album.in_yu?

      print "Uploading [#{album.id}] #{album.full_info} (#{album.year})\n"
      download_url = upload_folder(album)

      if download_url.present?
        tracklist = fetch_tracks(album)
        album.update_attributes(download_url: download_url, tracklist: tracklist, drive_id: CURRENT_DRIVE_ID)
        print "Success\n".green
      else
        print "Failed :(\n".red
      end
    end
  end

  def upload_folder(album)
    FileUtils.copy_entry("#{download_path}/#{album.id}", "#{upload_path}/#{album.id}")
    FileUtils.rm_r("#{upload_path}/#{album.id}/.DS_Store") if File.directory?("#{upload_path}/#{album.id}/.DS_Store")

    success = system("#{drive_program} push -no-prompt=true '#{upload_path}/#{album.id}'")
    return nil if !success

    result = `#{drive_program} pub '#{upload_path}/#{album.id}'`
    folder_id = result.split('https://drive.google.com/open?id=').last if result.include?('published')
    if folder_id
      FileUtils.rm_r("#{upload_path}/#{album.id}")
      "https://drive.google.com/folderview?id=#{folder_id}"
    end
  end

  def fetch_tracks(album)
    result = `(cd '#{upload_path}' && #{drive_program} list -long --sort name #{album.id})`
    return nil if result.include?("cannot be found remotely")
    tracks = result.split("\n").select{ |r| r =~ /mp3$/i }
    tracks = tracks.map{ |r| r.split("\t").values_at(1, -1) }
    tracks = tracks.map{ |r| [r[0], r[1].sub("/#{album.id}/", '').sub(/\.mp3$/i, '').unicode_normalize].join(";") }
    tracks.join("\n")
  end

  private

  def download_path
    "#{Rails.root}/tmp/downloads"
  end

  def upload_path
    "#{Rails.root}/tmp/uploads"
  end

  def drive_program
    "~/go/bin/drive"
  end

end
