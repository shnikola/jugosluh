require 'fileutils'
require 'shellwords'

class Downloader

  include Downloader::Domains

  def start(from_id = nil)
    Source.to_download.where("id >= ?", from_id || 0).find_each do |source|
      print "Downloading #{source.download_url}\n"
      print "S: #{source.title} (#{source.id})\n"
      print "A: #{source.album} #{source.album.year} (#{source.album_id})\n"

      if existing_source = Source.downloaded.where(album_id: source.album_id).first
        print "Already downloaded as #{existing_source.title} (#{existing_source.id})\n".light_blue
        source.downloaded!
        next
      end

      file_name = get_file(source.download_url)

      if file_name
        folder = extract_file(source, file_name)
        check_downloaded(source, folder)
        print "#{source.status.humanize} [#{file_name}]\n".send(source.downloaded? ? :green : :yellow)
      else
        source.download_failed!
        print "Failed :(\n".red
      end
    end
  end

  def extract_file(source, file)
    folder = "#{download_path}/_#{source.album_id}"
    Dir.mkdir(folder) unless File.directory?(folder)
    FileUtils.mv("#{download_path}/#{file}", "#{folder}/#{file}")

    escaped_file = file.shellescape
    password = archive_password(source.origin_site)
    if file.end_with? 'rar'
      `unrar x #{('-p' + password) if password} #{folder}/#{escaped_file} #{folder} && rm #{folder}/#{escaped_file}`
    elsif file.end_with? 'zip'
      `unzip #{('-P ' + password) if password} #{folder}/#{escaped_file} -d #{folder} && rm #{folder}/#{escaped_file}`
    end

    # If we extracted a folder, move the files out of it
    extracted = Dir.glob("#{folder}/*")
    if extracted.size == 1 && File.directory?(extracted.first)
      `mv #{extracted.first.shellescape}/* #{folder}/ && rm -r #{extracted.first.shellescape}`
    end

    # Fix permissions
    `chmod -R 777 "#{folder}"`

    # Clean up crud
    `find "#{folder}" -name '*.db' -delete`
    `find "#{folder}" -name '*.ico' -delete`
    `find "#{folder}" -name '*.ini' -delete`

    folder
  end

  def check_downloaded(source, folder)
    if Dir.glob("#{folder}/*.{mp3,flac}", File::FNM_CASEFOLD).count != source.album.tracks
      source.download_mismatched!
    else
      source.downloaded!
    end

    new_folder = "#{download_path}/#{folder_name(source)}"
    return if folder == new_folder

    new_folder += "_d" if File.directory?(new_folder)
    FileUtils.mv(folder, new_folder)
  end

  def folder_name(source)
    if source.downloaded?
      "#{source.album_id}"
    elsif source.incomplete? || source.download_mismatched?
      "t_#{source.album_id}_#{source.id}"
    else
      "e_#{source.album_id}"
    end
  end

  def download_path
    "#{Rails.root}/tmp/downloads"
  end

  def archive_password(site)
    {
      "yukebox.blogspot.hr" => "yukebox.blogspot.com",
      "yugojazz.blogspot.com" => "yugojazz"
    }[site]
  end

end
