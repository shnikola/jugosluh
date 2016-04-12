require "open-uri"

class Collector
  class MuzikaNarodna < Blogspot

    def crawl(options = {})
      @options = options
      find_posts("http://muzikanarodna.blogspot.hr") do |post|
        crawl_post(post)
      end
    end

    def crawl_post(post)
      title = post.css(".post-title").text.strip.to_lat
      artist = title.split("-").first.strip.to_lat
      details = post.css(".post-body").text.squish.strip.to_lat

      print "Searching #{title} " if @options[:trace]

      download_link = find_download_links(post).first

      if download_link
        download_url = download_link['href'].strip
        catnum = Catnum.guess(download_link.text)
        year = download_link.text.match(/\((\d{4})\)/).try(:[], 1).try(:to_i)
      end

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
        catnum: catnum,
        download_url: download_url,
        origin_site: 'muzikanarodna.blogspot.hr',
        status: :confirmed
      )

      if @options[:trace]
        print "...Success.\n".green
      else
        print "Found: #{artist} : #{title}\n".green
      end

      @options[:after].call(source) if @options[:after]
    end

  end
end
