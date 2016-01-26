require "open-uri"

class Collector
  module Jugorockforever

    def jugorockforever_crawl
      page = Nokogiri::HTML(open("http://jugorockforever.blogspot.com"))
      loop do
        page.css(".post").each { |p| jugorockforever_crawl_post(p) }
        next_page_link = page.css("a.blog-pager-older-link").first
        break if next_page_link.blank?
        page = Nokogiri::HTML(open(next_page_link["href"]))
      end
    end

    def jugorockforever_crawl_post(post)
      title = post.css(".post-title").text.strip
      artist = title.split("-").first.strip.downcase.capitalize
      details = post.css(".post-body").text.gsub(/download/i, "").strip.squish

      print "Searching #{title} " if @trace

      download_url = nil
      Downloader::Domains::SHARE_SITE_DOMAINS.keys.each do |domain|
        link = post.css("a[href*=\"#{domain}\"]").first
        if link
          download_url = link['href'].strip
          break
        end
      end

      if download_url.blank?
        print "...No link found.\n".red if @trace
        return
      elsif Source.where(download_url: download_url).exists?
        print "...Already collected.\n" if @trace
        return
      end

      source = Source.create(
        title: title,
        artist: artist,
        details: details,
        download_url: download_url,
        origin_site: 'jugorockforever.blogspot.com'
      )

      if @trace
        print "...Success.\n".green
      else
        print "Found: #{artist} : #{title}\n".green
      end

      if title =~ /\b(19\d\d)-(19)?\d\d\b/ || title =~ /\bdemo\b/i
        source.compilation!
      elsif title =~/\b(19\d\d)\b/
        source.confirmed!
      end

      add_to_collected(source)
    end

  end
end
