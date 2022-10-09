class DiscogsApi

  SEARCH_URL = 'https://api.discogs.com/database/search'

  def search(params = {})
    params = params.merge(page: 1, per_page: 100, type: 'release', country: 'Yugoslavia')
    loop do
      response = http_get(SEARCH_URL, params)
      response[:results].each do |result|
        yield result
      end
      pagination = response[:pagination]
      if params[:page] == 1
        print "Searhing discogs... #{pagination[:items]} items in #{pagination[:pages]} pages.".black.on_red + "\n"
      end
      break if params[:page] >= pagination[:pages]
      params[:page] = params[:page] + 1
    end
  end

  RELEASE_URL = 'https://api.discogs.com/releases'

  def get(id)
    http_get("#{RELEASE_URL}/#{id}")
  end

  MASTER_URL = 'https://api.discogs.com/masters'

  def get_master_release_ids(master_id)
    params = { page: 1, per_page: 100, country: 'Yugoslavia' }
    release_ids = []
    loop do
      response = http_get("#{MASTER_URL}/#{master_id}/versions", params)
      release_ids += response[:versions].map{|r| r[:id] }
      break if params[:page] >= response[:pagination][:pages]
      params[:page] = params[:page] + 1
    end
    release_ids
  end

  private

  def http_get(url, params = {})
    loop do
      sleep 1 # Simplest rate limiter
      full_url = params.present? ? "#{url}?#{params.to_query}" : url
      response = HTTP.timeout(6).accept(:json).auth(auth_details).get(full_url)
      if response.status.success?
        return JSON.parse(response.body.to_s, symbolize_names: true)
      end
      print "Status #{response.status}, retrying...\n".black.on_red
    rescue HTTP::ConnectionError, HTTP::TimeoutError => e
      print "#{e}, retrying...\n".black.on_red
      retry
    end
  end

  def auth_details
    "Discogs key=IjTxrhRngvXjeNYPCuUa, secret=kKiEXNKaZDuCroWaoHJZOIkDoWyQBYBn"
  end
end
