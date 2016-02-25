class Collector
  class MuzikaBalkana < Blogspot

    def crawl(options = {})
      @options = options
      find_posts("http://muzika-balkana.blogspot.hr") do |post|
        crawl_post(post)
      end
    end

    def crawl_post(post)
      title = post.css(".post-title").text.to_lat.strip
      artist = title.split("-").first.downcase.capitalize

      print "#{title}" if @options[:trace]
      year = title.match(/\((\d{4})\)/).try(:[], 1).try(:to_i)

      if year && year >= 1992
        print "...Not in YU.\n" if @options[:trace]
        return
      end

      details = post.css(".post-body").text.gsub(/You might also like.*/, '').strip.squish

      download_link = find_download_links(post).first

      # Try url shorteners
      if download_link.nil?
        download_link = post.css("a[href*=\"bit.ly\"]").first
        if download_link
          redirect_uri = open(download_link['href'], allow_redirections: :all).base_uri rescue nil
          # Sometimes there is an interim page
          redirect_uri = CGI.parse(redirect_uri.query)['url'].first if redirect_uri && redirect_uri.host.include?("bitly.com")
          download_link['href'] = redirect_uri.to_s if redirect_uri
        end
      end

      if download_link
        # Remove years for better catnum resolving
        catnum_text = download_link.text.squish.gsub(/19\d\d(\.g)?\s*$/i, "")
        catnum = Catnum.guess(catnum_text)
        download_url = download_link['href'].strip
      end

      # There is a lot of non-yu stuff on this blog, so collect only albums we recognize catnums of.
      if download_link.blank?
        print "...No link found.\n".red if @options[:trace]
        return
      elsif catnum.blank?
        print "...No catnum found (#{download_link.text}).\n".red if @options[:trace]
        return
      elsif Source.where(download_url: download_url).exists?
        print "...Already collected.\n" if @options[:trace]
        return
      end

      source = Source.create(
        title: title,
        artist: artist,
        catnum: catnum,
        details: details,
        status: :confirmed,
        download_url: download_url,
        origin_site: 'muzika-balkana.blogspot.hr'
      )

      if @options[:trace]
        print "...Success (#{catnum}).\n".green
      else
        print "Found: #{title} #{catnum}\n".green
      end

      @options[:after].call(source) if @options[:after]
    end

  end
end
