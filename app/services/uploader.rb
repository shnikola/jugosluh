class Uploader
  
  def start
    Source.downloaded.order("download_url").each do |source|
      album = source.album
      next if album.uploaded?

      p "Uploading #{album.id} [#{album.folder_name}]"      
      download_url = upload_folder(album)
      
      if download_url.present?
        album.update_attributes(download_url: download_url)
        p "Success"
      else
        p "Failed :("
      end
    end  
  end
  
  def upload_folder(album)
    FileUtils.copy_entry("#{download_path}/#{album.id}", "#{upload_path}/#{album.id}")
    success = system("#{drive_program} push -no-prompt=true '#{upload_path}/#{album.id}'")
    if success
      result = `#{drive_program} pub '#{upload_path}/#{album.id}'`
      result.match(/Published on (.*)$/).try(:[], 1)
    end
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