class Collector
  class Yukebox < Blogspot

    def crawl(options = {})
      @options = options
      find_posts("http://yukebox.blogspot.hr") do |post|
        crawl_post(post)
      end
    end

    def crawl_post(post)
      title = post.css(".post-title").text.strip
      artist = title.split("-").first

      print "#{title}" if @options[:trace]

      details = post.css(".post-body").text.strip.squish

      download_link = find_download_links(post).first
      download_url = download_link['href'].strip if download_link

      if download_url.blank?
        print "...No link found.\n".red if @options[:trace]
        return
      elsif Source.where(download_url: download_url).exists?
        print "...Already collected.\n" if @options[:trace]
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

      if @options[:trace]
        print "...Success (#{catnum}).\n".green
      else
        print "Found: #{title}\n".green
      end

      @options[:after].call(source) if @options[:after]
    end

  end
end
