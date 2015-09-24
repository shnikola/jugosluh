class Collector
  include Collector::Smboemi
  include Collector::Jugorockforever

  def initialize(**options)
    @trace = options[:trace]
  end

  def start
    smboemi_crawl
    jugorockforever_crawl
  end

  def finalize_source(source)
    connect_to_album(source)
  end

  def connect_to_album(source)
    albums = source.possible_albums

    if albums.count == 0
      print "  Album not found.\n"
    elsif albums.count == 1
      print "  Album Recognized: #{albums.first}\n"
    else
      print "  Possible Albums: #{albums.map(&:to_s).join(', ')}\n"
    end

    source.update_attributes(album_id: albums.first.id) if albums.first
  end

end
