class Collector
  class Jugozvuk < Blogspot

    def crawl(options = {})
      @options = options
      find_posts("http://jugozvuk.blogspot.com/") do |post|
        crawl_post(post)
      end
    end

    def crawl_post(post)
      title = post.css(".post-title").text.to_lat.strip
      artist = title.split("-").first if title.include?("-")
      artist ||= title.match(/((?:[A-ZČŠĆĐŽ]{2,}\s*)+)/).try(:[], 1)
      artist = artist.strip.capitalize if artist

      print "#{title}" if @options[:trace]
      year = title.match(/(\d{4})/).try(:[], 1).try(:to_i)
      details = post.css(".post-body").text.to_lat.strip.squish

      if year && year >= 1992
        print "...Not in YU.\n" if @options[:trace]
        return
      elsif title =~ /radio emisija/i || details =~ /radio emisija/i
        print "...Radio emisija.\n" if @options[:trace]
      end

      download_link = find_download_links(post).first
      download_url = download_link['href'].strip if download_link

      if download_url.blank?
        print "...No link found.\n".red if @options[:trace]
        return
      elsif Source.where(download_url: download_url).exists?
        print "...Already collected.\n" if @options[:trace]
        return
      end

      source = Source.create(
        title: title,
        artist: artist,
        details: details,
        download_url: download_url,
        status: :confirmed,
        origin_site: 'jugozvuk.blogspot.com'
      )

      if @options[:trace]
        print "...Success.\n".green
      else
        print "Found: #{title}\n".green
      end

      @options[:after].call(source) if @options[:after]
    end

  end
end
