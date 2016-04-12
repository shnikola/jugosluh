require 'fileutils'
require 'shellwords'

class Downloader

  include Downloader::Domains

  def start(source_ids = nil)
    downloaded = []

    sources = source_ids ? Source.where(id: source_ids) : Source.all
    sources.to_download.find_each do |source|
      download_source(source)
      downloaded << source.album if source.downloaded?
    end

    Cleaner.new.after_download(downloaded.map(&:id))
  end

  def download_source(source)
    print "Downloading #{source.download_url}\n"
    print "S: #{source.title} (#{source.id})\n"
    print "A: #{source.album} #{source.album.year} (#{source.album_id})\n"

    if Source.downloaded.exists?(album_id: source.album_id) || source.album.uploaded?
      print "Already downloaded\n".light_blue
      source.downloaded!
      return source
    end

    file_name = get_file(source.download_url)

    if file_name
      folder = extract_file(source, file_name)
      check_downloaded(source, folder)
      print "#{source.status.humanize} [#{file_name}]\n".colorize(source.downloaded? ? :green : :yellow)
    else
      source.download_failed!
      print "Failed :(\n".red
    end

    source
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
    elsif file.end_with? '7z'
      `7z x #{('-p' + password) if password} #{folder}/#{escaped_file} -o#{folder} && rm #{folder}/#{escaped_file}`
    end

    `find #{folder} -mindepth 2 -type f -exec mv {} #{folder} \\;` # Move all the files out of folders
    `find #{folder} -empty -type d -delete` # Delete all empty folders

    # Fix permissions
    `chmod -R 777 "#{folder}"`

    # Clean up crud
    `find "#{folder}" -name '*.db' -delete`
    `find "#{folder}" -name '*.ico' -delete`
    `find "#{folder}" -name '*.ini' -delete`
    `find "#{folder}" -name '*.url' -delete`

    folder
  end

  def check_downloaded(source, folder)
    if source.album.tracks.nil?
      print "No tracks info.\n".yellow
      source.downloaded!
    elsif track_count_matches?(source.album, folder)
      source.downloaded!
    else
      source.download_mismatched!
    end

    new_folder = "#{download_path}/#{folder_name(source)}"
    return if folder == new_folder

    new_folder += "_d" if File.directory?(new_folder)
    FileUtils.mv(folder, new_folder)
  end

  def track_count_matches?(album, folder)
    Dir.glob("#{folder}/*.mp3", File::FNM_CASEFOLD).count == album.tracks
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
