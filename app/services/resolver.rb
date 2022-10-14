class Resolver
  ENV['SPOTIFY_ACCESS_TOKEN'] = 'BQAdvZeyWcaNZwnbLBIrfNCsk0mj-CmUYbOpXdz15BcgEIynFvn79B5vWaBUYGJANDTuPuq6_kYnyK2z964ptcLe73lm9s4xsbGyls41plLc1_xqtoAq0WDYNqH2IcobL-7gtW5IoWu2jRcw_t3hhcy3XTsO4aCObzyBv_SvrEAfuwv333H6aHLLeOCVCiEZM2U'

  def connect_with_spotify
    Album.where(spotify_id: nil, id: 40058..500_000).find_each do |album|
      next if album.track_count.nil?

      print "Searching #{album.id}: #{album} (#{album.year}), #{album.track_count} tracks)\n".white.on_blue
      results = search_api(album.title.first(80))

      results.each do |res|
        item = {
          spotify_id: res["id"],
          artist: res["artists"].to_a.map{|a| a["name"]}.join(", "),
          title: res["name"],
          year: res["release_date"].to_s.split("-")&.first&.to_i,
          track_count: res["total_tracks"],
        }

        matched = album.track_count == item[:track_count] &&
                  item[:year] < 1991 &&
                  normalize_title(album.title) == normalize_title(item[:title])

        if matched
          album.update(spotify_id: item[:spotify_id])
          print "#{item[:artist]} - #{item[:title]} (#{item[:year]}), #{item[:track_count]} tracks\n".green
          break
        else
          print "#{item[:artist]} - #{item[:title]} (#{item[:year]}), #{item[:track_count]} tracks\n"
        end
      end

      print "\n"
    end
  end

  private

  def search_api(query)
    response = HTTP.auth("Bearer #{ENV['SPOTIFY_ACCESS_TOKEN']}").get("https://api.spotify.com/v1/search",
      params: { type: "album", limit: 5, q: "#{query}"}
    ).parse
    response["albums"]["items"]
  rescue HTTP::ConnectionError, HTTP::TimeoutError, OpenSSL::SSL::SSLError => e
    print "#{e}, retrying...\n".black.on_red
    retry
  end

  def normalize_title(title)
    title.gsub("\w", "").downcase.gsub(/[ščćžđ]/, "ž" => "z", "š" => "s", "č" => "c", "ć" => "c", "đ" => "dj")
  end

end
