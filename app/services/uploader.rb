class Uploader
  
  def start
    Source.downloaded.find_each do |source|
      album = source.album
      next if album.uploaded?
      
      download_url = upload_folder(album)
      
      if download_url.present?
        album.update_attributes(download_url: download_url)
        p "OK: #{album.folder_name}"
      else
        p "Fail: #{album.folder_name}"
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