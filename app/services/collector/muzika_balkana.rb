require "open-uri"

class Collector
  module MuzikaBalkana

    def muzika_balkana_crawl
      page = Nokogiri::HTML(open("http://muzika-balkana.blogspot.hr"))
      loop do
        page.css(".post").each { |p| muzika_balkana_crawl_post(p) }
        next_page_link = page.css("a.blog-pager-older-link").first
        break if next_page_link.blank?
        page = Nokogiri::HTML(open(next_page_link["href"]))
      end
    end

    def muzika_balkana_crawl_post(post)
      title = post.css(".post-title").text.to_lat.strip
      artist = title.split("-").first.downcase.capitalize

      print "#{title}" if @trace
      year = title.match(/\((\d{4})\)/).try(:[], 1).try(:to_i)

      if year && year > 1992
        print "...Not in YU.\n"  if @trace
        return
      end

      details = post.css(".post-body").text.gsub(/You might also like.*/, '').strip.squish

      download_link = nil
      Downloader::Domains::SHARE_SITE_DOMAINS.keys.each do |domain|
        download_link = post.css("a[href*=\"#{domain}\"]").first
        break if download_link
      end

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
        print "...No link found.\n".red if @trace
        return
      elsif catnum.blank?
        print "...No catnum found (#{download_link.text}).\n".red if @trace
        return
      elsif Source.where(download_url: download_url).exists?
        print "...Already collected.\n" if @trace
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

      if @trace
        print "...Success (#{catnum}).\n".green
      else
        print "Found: #{title} #{catnum}\n".green
      end

      source.confirmed!

      add_to_collected(source)
    end

  end
end
