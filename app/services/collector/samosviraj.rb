require "open-uri"

class Collector
  module Samosviraj

    def samosviraj_crawl
      page = Nokogiri::HTML(open("http://samosviraj.blogspot.hr/"))
      loop do
        page.css(".post").each { |p| samosviraj_crawl_post(p) }
        next_page_link = page.css("a.blog-pager-older-link").first
        break if next_page_link.blank?
        page = Nokogiri::HTML(open(next_page_link["href"]))
      end
    end

    def samosviraj_crawl_post(post)
      title = post.css(".post-title").text.gsub("(Singl)", "").strip
      artist = title.split("-").first.gsub(/\(.*\)/, '')

      print "#{title}" if @trace
      year = title.match(/\((\d{4})\)/).try(:[], 1).try(:to_i)

      if year && year > 1992
        print "...Not in YU.\n"  if @trace
        return
      end

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

      source = Source.create(
        title: title,
        artist: artist,
        details: details,
        download_url: download_url,
        origin_site: 'samosviraj.blogspot.hr'
      )

      if @trace
        print "...Success.\n".green
      else
        print "Found: #{title}\n".green
      end

      if year && year < 1992
        source.confirmed!
      end

      add_to_collected(source)
    end

  end
end
