class Uploader
  
  def start
    Source.downloaded.first(1).each do |source|
      next if source.album.uploaded?
      
      if !track_count_ok?(source.album)
        p "Tracks don't match: #{source.album.folder_name}"
        next
      end
      
      download_url = upload_folder(source.album)
      
      if download_url.present?
        source.album.update_attributes(download_url: download_url)
        p "OK: #{source.album.folder_name}"
      else
        p "Fail: #{source.album.folder_name}"
      end
    end  
  end
  
  def track_count_ok?(album)
    Dir.glob("#{download_path}/#{album.id}/*.{mp3,flac}").count == album.tracks
  end
  
  def upload_folder(album)
    FileUtils.mv("#{download_path}/#{album.id}", "#{upload_path}/#{album.folder_name}")
    upload_url = `#{drive_program} push "#{upload_path}/#{album.folder_name}" && #{drive_program} pub "#{album.folder_name}"`
  end
  
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