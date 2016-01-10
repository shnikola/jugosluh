class Uploader

  CURRENT_DRIVE_ID = 17

  def start(*ids)
    ids = Source.downloaded.pluck(:album_id) if ids.empty?
    Album.where(id: ids).where("year > 0").order("year").each do |album|
      next if album.uploaded? || !album.in_yu?

      print "Uploading #{album.id} [#{album.full_info}]\n"
      download_url = upload_folder(album)

      if download_url.present?
        album.update_attributes(download_url: download_url, drive_id: CURRENT_DRIVE_ID)
        print "  Success\n".green
      else
        print "  Failed :(\n".red
      end
    end
  end

  def upload_folder(album)
    FileUtils.copy_entry("#{download_path}/#{album.id}", "#{upload_path}/#{album.id}")
    success = system("#{drive_program} push -no-prompt=true '#{upload_path}/#{album.id}'")
    return nil if !success

    result = `#{drive_program} pub '#{upload_path}/#{album.id}'`
    folder_id = result.match(/https:\/\/googledrive.com\/host\/(.*)$/).try(:[], 1)
    if folder_id
      FileUtils.rm_r("#{upload_path}/#{album.id}")
      "https://drive.google.com/folderview?id=#{folder_id}"
    end
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
