require 'fileutils'
require 'shellwords'

class Downloader
  
  include Downloader::Domains
  
  def start(from_id = nil)
    Source.to_download.where("id >= ?", from_id || 0).find_each do |source|
      next if source.album.uploaded? || Source.where(album_id: source.album_id).count > 1
      if file_name = get_file(source.download_url)
        folder = extract_file(source.album, file_name)
        p "OK: [#{source.album_id}] #{source.album.artist} - #{source.album.title} : #{file_name}"
        source.update_attributes(downloaded: true)
      else
        p "Failed: [#{source.album_id}] #{source.album.artist} - #{source.album.title}"
      end
    end
  end
  
  def get_file(url)
    host = URI.parse(url.gsub(/#.*/, "")).host
    host = host.gsub(".", "_")
    send(:"get_#{host}", url)
  end
  
  def extract_file(album, file)
    folder = "#{download_path}/#{album.id}"
    Dir.mkdir(folder) unless File.directory?(folder)
    #FileUtils.mv("#{download_path}/#{file}", "#{folder}/#{file}")
    if file.end_with? 'rar'
      `unrar x '#{folder}/#{file}' '#{folder}' && rm '#{folder}/#{file}'`
    elsif file.end_with? 'zip'
      `unzip '#{folder}/#{file}' -d '#{folder}' && rm '#{folder}/#{file}'`
    end
    
    # If we extracted a folder, move the files out of it
    extracted = Dir.glob("#{folder}/*")
    if extracted.size == 1 && File.directory?(extracted.first)
      `mv '#{extracted.first}'/* "#{folder}/" && rm -r '#{extracted.first}'`
    end
    
    # Clean up crud
    `find "#{folder}" -name '*.db' -delete`
    `find "#{folder}" -name '*.ico' -delete`
    `find "#{folder}" -name '*.ini' -delete`
    
    folder
  end
  
  
  def download_path
    "#{Rails.root}/tmp/downloads"
  end
  
end