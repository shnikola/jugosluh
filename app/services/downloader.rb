require 'fileutils'
require 'shellwords'

class Downloader
  
  include Downloader::Domains
  
  def start(from_id = nil)
    Source.to_download.where("download_url LIKE '%file-upload%'").where("id >= ?", from_id || 0).find_each do |source|
      next if source.album.uploaded?
      
      p "Downloading #{source.id} [#{source.album}]"
      file_name = get_file(source.download_url)
      
      if file_name
        folder = extract_file(source, file_name)
        check_downloaded(source, folder)
        p "Success [#{file_name}]"
      else
        source.download_failed!
        p "Failed :("
      end
    end
  end
  
  def extract_file(source, file)
    folder = "#{download_path}/_#{source.album_id}"
    Dir.mkdir(folder) unless File.directory?(folder)
    FileUtils.mv("#{download_path}/#{file}", "#{folder}/#{file}")
    
    escaped_file = file.shellescape
    if file.end_with? 'rar'
      `unrar x #{folder}/#{escaped_file} #{folder} && rm #{folder}/#{escaped_file}`
    elsif file.end_with? 'zip'
      `unzip #{folder}/#{escaped_file} -d #{folder} && rm #{folder}/#{escaped_file}`
    end
    
    # If we extracted a folder, move the files out of it
    extracted = Dir.glob("#{folder}/*")
    if extracted.size == 1 && File.directory?(extracted.first)
      `mv #{extracted.first.shellescape}/* #{folder}/ && rm -r #{extracted.first.shellescape}`
    end
    
    # Clean up crud
    `find "#{folder}" -name '*.db' -delete`
    `find "#{folder}" -name '*.ico' -delete`
    `find "#{folder}" -name '*.ini' -delete`
    
    folder
  end
  
  def check_downloaded(source, folder)
    if Dir.glob("#{folder}/*.{mp3,flac}", File::FNM_CASEFOLD).count != source.album.tracks
      source.download_mismatched!
    elsif Source.downloaded.where(album_id: source.album_id).where("id != ?", source.id).exists?
      source.multiple_found! 
    else
      source.downloaded!
    end
    
    new_folder = "#{download_path}/#{folder_name(source)}"
    FileUtils.mv(folder, new_folder) if folder != new_folder
  end
  
  def folder_name(source)
    if source.multiple_found?
      "m_#{source.album_id}_#{source.id}"
    elsif source.download_mismatched?
      "t_#{source.album_id}_#{source.id}"
    elsif source.downloaded?
      "#{source.album_id}"
    else
      "e_#{source.album_id}"
    end
  end
  
  def download_path
    "#{Rails.root}/tmp/downloads"
  end
  
end