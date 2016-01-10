class Collector
  include Collector::Smboemi
  include Collector::Jugorockforever

  def initialize(**options)
    @trace = options[:trace]
    @collected = []
  end

  def start
    smboemi_crawl
    jugorockforever_crawl

    Cleaner.new.after_collecting(@collected.map(&:id))
  end

  private

  def add_to_collected(source)
    @collected.push(source)
  end

end
