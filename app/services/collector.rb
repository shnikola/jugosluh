class Collector
  include Collector::Smboemi
  include Collector::Jugorockforever
  
  def start
    smboemi_crawl
    jugorockforever_crawl
  end
  
  def finalize_source(source)
    connect_to_album(source)
  end
    
  def connect_to_album(source)
    album_by_catnum = Album.find_original_by_catnum(source.catnum) if source.catnum.present? 
    album_by_title = Album.find_original_by_title(source.title) if source.title.present?
    
    if album_by_catnum && album_by_title && album_by_catnum != album_by_title
      p "  Possible Albums: #{album_by_catnum} (#{album_by_catnum.id}) :: #{album_by_title} (#{album_by_title.id})"
      source.update_attributes(album_id: album_by_catnum.id)
    
    elsif album_by_catnum || album_by_title
      album = album_by_catnum || album_by_title
      p "  Album Recognized: #{album}"
      source.update_attributes(album_id: album.id)
    end
  end
  
end