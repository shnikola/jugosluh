require "open-uri"

class Collector
  module Smboemi
  
    def smboemi_crawl(&block)
      page_ids = [
        35..57,
        62..84,
        103..124,
        131..152,
        277..297,
        375..396,
        424..445,
        469..472,
        514..517,
        540..542
      ].map(&:to_a).sum + [
        188,
        215,
        269,
        548,
        551
      ]
      
      page_ids.each do |id|
        noko = Nokogiri::HTML(open("http://www.smboemi.com/archive/index.php/f-#{id}.html"))
        noko.css("#content a").each do |thread_link|
          smboemi_crawl_thread(thread_link["href"], &block)
        end
      end
    end

    def smboemi_crawl_thread(url)
      post_title = noko.css(".largefont a").text
      artist = post_title.match(/(.*) - (diskografija|kolekcija)/i).try(:[], 1).try(:strip)
      artist ||= post_title.split("-")[0].gsub(/\d{4}/, '').strip
      
      noko.css(".posttext").each do |content|
        text = content.text
        next unless text.include? "]!"
        mega_id = text.match(/](!.+)/)[1].strip
        download_url = "http://mega.co.nz/##{mega_id}"
        next if Source.where(download_url: download_url).exist?
        
        clean_lines = text.lines.reject{|l| l.strip.start_with?("[Samo") || l.blank?}
        title = clean_lines[0].try(:first, 255).try(:strip)
        source = Source.create(
          title: title,
          artist: artist,
          catnum: catnum_guess(details),
          details: clean_lines.join("\n"),
          download_url: download_url
        )
        yield source
      end
    end
    
  end
end