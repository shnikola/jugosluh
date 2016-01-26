require "open-uri"

class Collector
  module Yukebox

    def yukebox_crawl
      page = Nokogiri::HTML(open("http://yukebox.blogspot.hr/"))
      loop do
        page.css(".post").each { |p| yukebox_crawl_post(p) }
        next_page_link = page.css("a.blog-pager-older-link").first
        break if next_page_link.blank?
        page = Nokogiri::HTML(open(next_page_link["href"]))
      end
    end

    def yukebox_crawl_post(post)
      title = post.css(".post-title").text.strip
      artist = title.split("-").first

      print "#{title}" if @trace

      details = post.css(".post-body").text.strip.squish

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

      catnum_line = details.lines.find{|l| l.start_with?("(P)")}
      catnum = Catnum.guess(details.lines.first)

      source = Source.create(
        title: title,
        artist: artist,
        catnum: catnum,
        details: details,
        status: :confirmed,
        download_url: download_url,
        origin_site: 'yukebox.blogspot.hr'
      )

      if @trace
        print "...Success (#{catnum}).\n".green
      else
        print "Found: #{title}\n".green
      end

      add_to_collected(source)
    end

  end
end
