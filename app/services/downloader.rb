require 'fileutils'
require 'shellwords'

class Downloader
  
  include Downloader::Domains
  
  def start(from_id = nil)
    Source.to_download.where("id >= ?", from_id || 0).find_each do |source|
      if source.album.uploaded?
        # Maybe track it somehow?
        next
      end
      
      if Source.where(album_id: source.album_id).count > 1
        source.multiple_found!
      end
      
      p "Downloading #{source.id} [#{source.album}]"
      file_name = get_file(source.download_url)
      
      if file_name
        folder = extract_file(source, file_name)
        source.downloaded! unless source.multiple_found?
        p "Success [#{file_name}]"
      else
        source.download_failed!
        p "Failed :("
      end
      
      if source.downloaded? && track_count_mismatch?(source, folder)
        source.download_mismatched!
      end
      
      source.save
    end
  end
  
  def get_file(url)
    host = URI.parse(url.gsub(/#.*/, "")).host
    host = host.gsub(".", "_")
    send(:"get_#{host}", url)
  end
  
  def extract_file(source, file)
    folder = "#{download_path}/#{source.album_id}"
    folder += "_m_#{source.id}" if source.multiple_found?
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
  
  def track_count_mismatch?(source, folder)
    Dir.glob("#{folder}/*.{mp3,flac}").count != source.album.tracks
  end
  
  def download_path
    "#{Rails.root}/tmp/downloads"
  end
  
end