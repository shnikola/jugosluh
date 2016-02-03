module DiscogsYu

  def self.find_each
    options = {country: 'yugoslavia', type: 'release'}
    options.merge!(per_page: 100, page: 1)
    loop do
      begin
        response = discogs.search(nil, options)
        response.results.each {|r| yield r}
        break if response.pagination.page >= response.pagination.pages
        options.merge!(page: response.pagination.page + 1)
      rescue EOFError => e
        print "EOF Error, retrying...\n".black.on_red
        retry
      rescue Errno::ECONNRESET => e
        print "Errno::ECONNRESET, retrying...\n".black.on_red
        retry
      end
    end
  end

  def self.find_by_id(id)
    return nil unless id
    sleep(0.5) # TODO: make this smarter
    discogs.get_release(id)
  rescue Discogs::UnknownResource => e
    print "Couldn't find: #{id}\n".black.on_red
    return nil
  rescue EOFError, OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
    print "#{e}, retrying...\n".black.on_red
    retry
  end

  def self.search_by_name(name, size = 10)
    options = {country: 'yugoslavia', type: 'release'}
    options.merge!(per_page: size, page: 1)
    begin
      response = discogs.search(name, options)
    rescue EOFError, OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
      print "#{e}, retrying...\n".black.on_red
      retry
    end
    response.results
  end

  def self.find_release_version_ids(master_id)
    discogs.get_master_release_versions(master_id).versions.map(&:id)
  end

  def self.discogs
    @@discogs ||= Discogs::Wrapper.new("Jugosluh", app_key: "IjTxrhRngvXjeNYPCuUa", app_secret: "kKiEXNKaZDuCroWaoHJZOIkDoWyQBYBn")
  end
end
