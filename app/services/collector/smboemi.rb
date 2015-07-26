require "open-uri"

class Collector
  module Smboemi
  
    def smboemi_crawl
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
          smboemi_crawl_thread(thread_link["href"])
        end
      end
    end

    def smboemi_crawl_thread(url)
      noko = Nokogiri::HTML(open(url))
      post_title = noko.css(".largefont a").text
      artist = post_title.match(/(.*) - (diskografija|kolekcija)/i).try(:[], 1).try(:strip)
      artist ||= post_title.split("-")[0].gsub(/\d{4}/, '').strip
      
      p "Artist: #{artist}"
      
      noko.css(".posttext").each do |content|
        text = content.text.encode("utf-8", invalid: :replace, undef: :replace, replace: '?')
        
        clean_lines = text.lines.map(&:strip).reject{|l| l.blank? || l.start_with?("[Samo") || l.match(/^-+$/)}
        title = clean_lines.first || ""
        
        print "  Searching #{title} "
        
        unless text.include? "]!"
          p "...No link found."
          next
        end
        
        mega_id = text.match(/](!.+)/)[1].strip
        download_url = "http://mega.co.nz/##{mega_id}"
        
        if Source.where(download_url: download_url).exists?
          p "...Already collected."
          next
        end
                
        year = title.match(/\D((?:19|20)\d\d)\D/).try(:[], 1).to_i
        
        if year > 1992
          p "...Not in YU."
          next
        end
        
        source = Source.create(
          title: title.first(255),
          artist: artist,
          catnum: Catnum.guess(clean_lines[0]) || Catnum.guess(clean_lines[1]),
          details: clean_lines.join("\n"),
          download_url: download_url
        )
        
        p "...SUCCESS."
        
        source.confirmed! if year.between?(1900, 1992)
        finalize_source(source)
      end
    end
    
  end
end