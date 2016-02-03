require "open-uri"

class Collector
  class Blogspot

    def find_posts(url)
      page = Nokogiri::HTML(open(url))
      loop do
        page.css(".post").each { |p| yield(p) }
        next_page_link = page.css("a.blog-pager-older-link").first
        break if next_page_link.blank?
        page = Nokogiri::HTML(open(next_page_link["href"]))
      end
    end

    def find_download_links(html)
      selector = Downloader::Domains::SHARE_SITE_DOMAINS.keys.map { |domain| "a[href*=\"#{domain}\"]" }.join(", ")
      html.css(selector)
    end


  end
end
