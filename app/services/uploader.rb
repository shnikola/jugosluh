class Uploader
  
  CURRENT_DRIVE_ID = 4
  
  def start(*ids)
    sources = Source.downloaded
    sources.where!(album_id: ids) if ids.present?
    sources.order("download_url").each do |source|
      album = source.album
      next if album.uploaded? || !album.in_yu?

      p "Uploading #{album.id} [#{album.folder_name}]"      
      download_url = upload_folder(album)
      
      if download_url.present?
        album.update_attributes(download_url: download_url, drive_id: CURRENT_DRIVE_ID)
        p "Success"
      else
        p "Failed :("
      end
    end
  end
  
  def upload_folder(album)
    FileUtils.copy_entry("#{download_path}/#{album.id}", "#{upload_path}/#{album.id}")
    success = system("#{drive_program} push -no-prompt=true '#{upload_path}/#{album.id}'")
    return nil if !success
    
    result = `#{drive_program} pub '#{upload_path}/#{album.id}'`
    folder_id = result.match(/Published on https:\/\/googledrive.com\/host\/(.*)$/).try(:[], 1)
    "https://drive.google.com/folderview?id=#{folder_id}"
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