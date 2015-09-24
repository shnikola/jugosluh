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

      download_link = post.css('a[href*="mega.co.nz"], a[href*="mega.nz"]').first ||
        post.css("a[href*=solidfiles]").first ||
        post.css("a[href*=file-upload]").first ||
        post.css("a[href*=zippyshare]").first ||
        post.css("a[href*=mediafire]").first
      download_url = download_link['href'].strip if download_link
      if download_url.blank?
        print "...No link found.\n" if @trace
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
        print "...SUCCESS.\n"
      else
        print "FOUND: #{artist} : #{title}\n"
      end

      if title =~ /\b(19\d\d)-(19)?\d\d\b/ || title =~ /\bdemo\b/i
        source.compilation!
      elsif title =~/\b(19\d\d)\b/
        source.confirmed!
      end

      finalize_source(source)
    end

  end
end
