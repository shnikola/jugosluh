class Collector
  include Collector::Smboemi
  include Collector::Jugorockforever
  
  def start
    smboemi_crawl
    jugorockforever_crawl
  end
  
  def finalize_source(source)
    connect_to_album(source)
    set_status(source)
  end
    
  def connect_to_album(source)
    album_by_catnum = Album.find_original_by_catnum(source.catnum) if source.catnum.present? 
    album_by_title = Album.find_original_by_title(source.title) if source.title.present?
    
    if album_by_catnum && album_by_title && album_by_catnum != album_by_title
      p "DIFF: #{album_by_catnum.title} (#{album_by_catnum.id}) :: #{album_by_title.title} (#{album_by_title.id}) [#{source.title}]"
    end
    
    album_id = (album_by_catnum || album_by_title).try(:id)
    p "CONN: #{source.id}: #{album_id}" if album_id
    source.update_attributes(album_id: album_id) if album_id
  end
  
  def set_status(source)
    if source.title.include?(/199[2-9]/) || source.title.include?(/20\d\d/)
      source.skipped!
    else
      source.confirmed!
    end
  end
  
end