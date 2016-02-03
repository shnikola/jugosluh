require "open-uri"

class Collector
  class Jugorockforever < Blogspot

    def crawl(options = {})
      @options = options
      find_posts("http://jugorockforever.blogspot.com") do |post|
        crawl_post(post)
      end
    end

    def crawl_post(post)
      title = post.css(".post-title").text.strip
      artist = title.split("-").first.strip.downcase.capitalize
      details = post.css(".post-body").text.gsub(/download/i, "").strip.squish

      print "Searching #{title} " if @options[:trace]

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
        origin_site: 'jugorockforever.blogspot.com'
      )

      if @options[:trace]
        print "...Success.\n".green
      else
        print "Found: #{artist} : #{title}\n".green
      end

      if title =~ /\b(19\d\d)-(19)?\d\d\b/ || title =~ /\bdemo\b/i
        source.compilation!
      elsif title =~/\b(19\d\d)\b/
        source.confirmed!
      end

      @options[:after].call(source) if @options[:after]
    end

  end
end
