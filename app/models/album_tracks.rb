require 'open-uri'

class AlbumTracks
  
  def self.fetch(album)
    return [] if album.download_url.blank?
    tracks = []
    
    noko = Nokogiri::HTML(open(album.download_url))
    noko.css(".flip-entry").each do |entry|
      id = entry["id"].gsub(/\Aentry-/, "")
      title = entry.css(".flip-entry-title").first.try(:text)
      if title && title =~ /\.mp3/i
        tracks.push(title: title.gsub(/.mp3/i, ''), url: "https://drive.google.com/uc?id=#{id}")
      end
    end
    
    tracks
  end
end
