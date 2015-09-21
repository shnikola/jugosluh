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
      download_link = post.css('a[href*="mega.co.nz"], a[href*="mega.nz"]').first ||
        post.css("a[href*=solidfiles]").first ||
        post.css("a[href*=file-upload]").first ||
        post.css("a[href*=zippyshare]").first ||
        post.css("a[href*=mediafire]").first
     
      download_url = download_link['href'].strip if download_link
      if download_url.blank?
        p "[No link found] #{title}"
        return
      elsif Source.where(download_url: download_url).exists?
        return
      end 
      
      source = Source.create(
        title: title,
        artist: artist,
        details: details,
        download_url: download_url,
        origin_site: 'jugorockforever.blogspot.com'
      )
      
      finalize_source(source)
    end

  end
end