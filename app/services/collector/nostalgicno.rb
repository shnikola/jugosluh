require "open-uri"

class Collector
  class Nostalgicno < Blogspot

    def crawl(options = {})
      @options = options
      find_posts("http://nostalgicno.blogspot.hr") do |post|
        crawl_post(post)
      end
    end

    def crawl_post(post)
      title = post.css(".post-title").text.strip
      artist = title.split("-").first.strip.downcase.capitalize

      print "#{title}" if @options[:trace]
      year = title.match(/(\d{4})/).try(:[], 1).try(:to_i)

      if year && year >= 1992
        print "...Not in YU.\n" if @options[:trace]
        return
      end

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
        status: :confirmed,
        download_url: download_url,
        origin_site: 'nostalgicno.blogspot.hr'
      )

      if @options[:trace]
        print "...Success.\n".green
      else
        print "Found: #{title}\n".green
      end

      @options[:after].call(source) if @options[:after]
    end

  end
end
