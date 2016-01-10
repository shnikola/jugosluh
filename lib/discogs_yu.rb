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
        p "EOF Error, retrying..."
        retry
      rescue Errno::ECONNRESET => e
        p "Errno::ECONNRESET, retrying..."
        retry
      end
    end
  end

  def self.find_by_id(id)
    return nil unless id
    sleep(0.5) # TODO: make this smarter
    discogs.get_release(id)
  rescue Discogs::UnknownResource => e
    p "Couldn't find: #{id}"
    return nil
  rescue EOFError, OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
    p "#{e}, retrying..."
    retry
  end

  def self.search_by_name(name, size = 10)
    options = {country: 'yugoslavia', type: 'release'}
    options.merge!(per_page: size, page: 1)
    begin
      response = discogs.search(name, options)
    rescue EOFError, OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
      p "#{e}, retrying..."
      retry
    end
    response.results
  end

  def self.discogs
    @@discogs ||= Discogs::Wrapper.new("Jugosluh", app_key: "IjTxrhRngvXjeNYPCuUa", app_secret: "kKiEXNKaZDuCroWaoHJZOIkDoWyQBYBn")
  end
end
