require "open-uri"

class Collector
  module Smboemi

    def smboemi_crawl
      page_ids = [
        35..57, 188,  # Diskografije/kolekcije zabavnjaka
        62..84, 215,  # Razni albumi i singlice
        103..124,     # Diskografije Narodne muzike
        131..152,     # Duetska izdanja
        276..297,     # Kolekcije, kompilacije, Noviteti
        375..396,     # Izvorna i krajiska muzika
        424..445,     # Narodna kola i igre
        515..517,     # Sevdalinke i starogradska muzika
        469..474, 514, 540..542, 551,  # Ripovi ostalih najpoznatijih ripera kod nas
        269,          # Novi clanovi nude Narodnu muziku
        548,          # Novi clanovi nude Zabavnu muziku
        349,          # Muzika za decu
      ].map{|i| Array(i) }.sum
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

      print "Artist: #{artist}\n" if @trace

      noko.css(".posttext").each do |content|
        text = content.text.encode("utf-8", invalid: :replace, undef: :replace, replace: '?')

        clean_lines = text.lines.map(&:strip).reject{|l| l.blank? || l.start_with?("[Samo") || l.match(/^[\.-]+$/)}
        title = clean_lines.first || ""

        print "  Searching #{title} " if @trace

        unless text.include? "]!"
          print "...No link found.\n" if @trace
          next
        end

        mega_id = text.match(/](!.+)/)[1].strip
        download_url = "https://mega.co.nz/##{mega_id}"

        if Source.where(download_url: download_url).exists?
          print "...Already collected.\n" if @trace
          next
        end

        if title =~ /^\d{3}\s*kbps$/i
          print "...No title found.\n" if @trace
          next
        end

        year = title.match(/\b((?:19|20)\d\d)\b/).try(:[], 1).to_i

        if year > 1992
          print "...Not in YU.\n"  if @trace
          next
        end

        source = Source.create(
          title: title.first(255),
          artist: artist,
          catnum: Catnum.guess(clean_lines[0]) || Catnum.guess(clean_lines[1]),
          details: clean_lines.join("\n"),
          download_url: download_url,
          origin_site: 'smboemi.com'
        )

        if @trace
          print "...Success.\n".green
        else
          print "Found: #{artist} : #{title}\n".green
        end


        source.confirmed! if year.between?(1900, 1992)
        add_to_collected(source)
      end
    end

  end
end
