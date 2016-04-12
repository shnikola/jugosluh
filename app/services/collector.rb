class Collector
  @@crawlers = [
    #Collector::Smboemi,
    Collector::Jugorockforever,
    Collector::Jugozvuk,
    Collector::MuzikaBalkana,
    Collector::MuzikaNarodna,
    Collector::Nostalgicno,
    Collector::SlovenianAlternative,
    Collector::Samosviraj,
    Collector::Yukebox,
  ]

  def initialize(**options)
    @trace = options[:trace]
    @collected = []
  end

  def start
    @@crawlers.each do |c|
      print "Collecting from #{c.name.demodulize.humanize}\n\n".on_blue
      c.new.crawl(trace: @trace, after: lambda { |s| add_to_collected(s) })
    end
    Cleaner.new.after_collecting(@collected.map(&:id))
  end

  private

  def add_to_collected(source)
    @collected.push(source)
  end

end
