module YuAlbums
  
  def self.fetch_all
    options = {country: 'yugoslavia', type: 'release'}
    options.merge!(per_page: 100, page: 1)
    loop do
      begin
        response = discogs.search(nil, options)
        response.results.each {|r| yield r}
        break if response.pagination.page >= response.pagination.pages
        options.merge!(page: response.pagination.page + 1)
      rescue EOFError => e
        p "EOF Error, retrying..."
        retry
      rescue Errno::ECONNRESET => e
        p "Errno::ECONNRESET, retrying..."
        retry
      end
    end
  end
  
  def self.load_to_db
    fetch_all do |release|
      begin
        next if Album.where(discogs_release_id: release.id).exists?
        sleep(0.5)
        Album.update_or_create_from_discogs(discogs.get_release(release.id))
      rescue Discogs::UnknownResource => e
        p "Couldn't find: #{release}"
        next
      rescue EOFError, OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
        p "#{e}, retrying..."
        retry
      end
    end
  end
  
  def self.load_tracks
    Album.of_interest.where(tracks: nil).find_each do |a|
      begin
        release = discogs.get_release(a.discogs_release_id)
        a.update_attributes(tracks: release.tracklist.size)
      rescue Discogs::UnknownResource => e
        p "Couldn't find: #{release}"
        next
      rescue EOFError, OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
        p "#{e}, retrying..."
        retry
      end
    end
  end
  
  def self.find_by_name(name)
    options = {country: 'yugoslavia', type: 'release'}
    options.merge!(per_page: 3, page: 1)
    begin
      response = discogs.search(name, options)
    rescue EOFError, OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
      p "#{e}, retrying..."
      retry
    end
    response.results.first
  end
  
  def self.discogs
    @@discogs ||= Discogs::Wrapper.new("Jugosluh", app_key: "IjTxrhRngvXjeNYPCuUa", app_secret: "kKiEXNKaZDuCroWaoHJZOIkDoWyQBYBn")
  end
end