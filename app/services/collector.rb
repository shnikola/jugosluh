class Collector
  include Collector::Smboemi
  
  def start
    crawl do |source| 
      connect_to_album(source)
    end
    # crawl_some_blogs
  end
  
  def crawl(&block)
    smboemi(&block)
  end
  
  def catnum_guess(details)
    line = details.lines.first
    line.gsub!("\u200E", "")
    if line =~ /Jugoton/i
      line.match(/Jugoton[\s–,-]+(?:Zagreb[\s–,-]+)?(?:LP )?(\w+[\s–-]*(?:S )?(?:-?\w)+)/i).try(:[],1)
    elsif line =~ /Beograd Disk/i
      line.match(/Beograd Disk(?:o|-a)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Jugodisk/i
      line.match(/Jugodisk(?:o|-a)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Diskoton/i
      line.match(/Diskoton(?:[\s,–-]+Sarajevo)?(?:[\s,–-]+DT)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Suzy/i
      line.match(/Suzy(?:[\s,–-]+Zagreb)?(?:[\s,–-]+records)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /RTB/i
      line.match(/(?:PGP[ -])?RTB|S(?:[\s,–-]+Beograd)?[\s–,-]*(\w*(?:[\s–-]+I+)?(?:[\s–-]+[\d]+)+)/i).try(:[], 1)
    end
    # TODO:  "Diskos", "Helidon",
  end
  
  def connect_to_album(source)
    album_by_catnum = Album.find_original_by_catnum(source.catnum) if source.catnum.present? 
    album_by_title = find_album_by_title(source.clean_title) if source.clean_title.present?
    
    if album_by_catnum && album_by_title && album_by_catnum != album_by_title
      p "DIFF: #{album_by_catnum.title} (#{album_by_catnum.id}) :: #{album_by_title.title} (#{album_by_title.id}) [#{source.title}]"
    end
    
    update_attributes(album_id: (album_by_catnum || album_by_title).try(:id))    
  end
  
  def find_album_by_title(title)
    release = YuAlbums.find_by_name(title)
    Album.find_by_discogs_release_id(release.id).original if release
  end
  
end