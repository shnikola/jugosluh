class Lister

  def list_duplicate_catnums
    album_map = Hash.new([])
    Album.where("catnum != ?", 'NONE').find_each do |album|
      album_map[album.label + "#" + album.catnum] += [album]
    end

    album_map.select!{|_, v| v.count > 1}
    album_map.values.each do |albums|
      albums.each { |a| print "[#{a.label} #{a.catnum}] #{a.artist} - #{a.title}\n"}
      print "\n"
    end
  end

  def list_collected_catnums
    total = Hash.new { |h, k| h[k] = { count: 0, estimated: 0} }
    Label::MAJOR_LABEL_PREFIXES.each do |label, prefixes|
      print "#{label}".on_red
      print "\n\n"
      catnums = Album.where(label: label).pluck(:catnum).flat_map{|c| c.split(";")}.uniq
      prefixes[:domestic].each do |prefix|
        prefix_catnums = catnums.select{|c| Label.prefix_match?(prefix, c)}
        prefix_estimated_total = prefix_catnums.count
        prefix_catnums = prefix_catnums.map{ |catnum| p, c = catnum.split("-", 2); [p, c.to_i] }.sort_by(&:last)
        prefix_catnums.each.with_index do |catnum, i|
          print "#{catnum[0]}-#{catnum[1]}  ".green
          break if i + 1 >= prefix_catnums.count
          diff = prefix_catnums[i + 1][1] - catnum[1] - 1
          if diff < 19
            prefix_estimated_total += diff
            diff.times { |d| print "#{catnum[0]}-#{catnum[1] + d + 1}  ".yellow }
          else
            print "\n"
          end
        end
        total[label][:count] += prefix_catnums.count
        total[label][:estimated] += prefix_estimated_total
        print "Collected #{prefix_catnums.count}/#{prefix_estimated_total} (#{(100.0 * prefix_catnums.count / prefix_estimated_total).round(2)}%)".on_blue
        print "\n\n"
      end
    end

    print "\n\n"
    total.each do |label, totals|
      print "#{label.ljust(20)}:".on_red
      print "  "
      print "#{totals[:count]}/#{totals[:estimated]}".ljust(12)
      print "(#{(100.0 * totals[:count] / totals[:estimated]).round(2)}%)".on_blue
      print "\n"
    end
    print "\n"
    print "#{'Total'.ljust(20)}:".on_red
    print "  "
    print "#{total.sum{|l, t| t[:count]}}/#{total.sum{|l, t| t[:estimated]}}".ljust(12)
    print "(#{(100.0 * total.sum{|l, t| t[:count]} / total.sum{|l, t| t[:estimated]}).round(2)}%)".on_blue
    print "\n"
  end

  def browse_missing_years
    Album.where("catnum != 'NONE'").group_by(&:label).each do |label, albums|
      print "#{label}\n\n".red
      window_size = 7
      middle = window_size / 2
      albums.sort_by(&:catnum).each_cons(window_size) do |cons|
        next if cons[middle].year?

        # Try to copy from neighbours
        if cons[middle-1].catnum == cons[middle].catnum && cons[middle-1].year?
          cons[middle].update(year: cons[middle-1].year)
        elsif cons[middle+1].catnum == cons[middle].catnum && cons[middle+1].year?
          cons[middle].update(year: cons[middle+1].year)
        end

        # Print window
        cons.each_with_index do |a, i|
          print "#{a.year || '    '} ".colorize(i == middle ? :blue : :green)
          print "#{a.catnum}\n".colorize(i == middle ? :yellow : :green)
        end

        # Take user input if we still have nothing
        if cons[middle].year.nil?
          #year = gets.strip
          #cons[3].update(year: "19#{year}") if year.present?
        else
          print "\n"
        end

      end
    end
  end

end
