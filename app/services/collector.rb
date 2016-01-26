class Collector
  include Collector::Smboemi
  include Collector::Jugorockforever
  include Collector::MuzikaBalkana
  include Collector::SlovenianAlternative
  include Collector::Samosviraj
  include Collector::Yukebox

  def initialize(**options)
    @trace = options[:trace]
    @collected = []
  end

  def start
    #smboemi_crawl
    #jugorockforever_crawl
    # muzika_balkana_crawl
    #samosviraj_crawl
    #slovenian_alternative_crawl
    yukebox_crawl
    Cleaner.new.after_collecting(@collected.map(&:id))
  end

  private

  def add_to_collected(source)
    @collected.push(source)
  end

end
