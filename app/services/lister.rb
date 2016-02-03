class Lister

  def list_duplicate_catnums
    album_map = Hash.new([])
    Album.original.maybe_in_yu.where("catnum != ?", 'NONE').find_each do |album|
      album_map[album.label + "#" + album.catnum] += [album]
    end

    album_map.select!{|_, v| v.count > 1}
    album_map.values.each do |albums|
      albums.each { |a| print "[#{a.label} #{a.catnum}] #{a.artist} - #{a.title}\n"}
      print "\n"
    end
  end

  def list_catnums
    total = 0
    estimated_total = 0
    labels = {
      "Jugoton" => ["C", "SY", "EPY", "LSY"],
      "PGP RTB" => [], # TODO
      "Diskos" => ["EDK", "LPD", "NDK"],
      "Diskoton" => ["DTK", "LP", "SN", "SZ"],
      "Beograd Disk" => ["BDN", "EBK", "EVK", "LPD", "SBK", "SVK"],
      "Suzy" => ["KS", "LP", "SP"],
      "Jugodisk" => ["BDN", "JDN", "LPD", "SVK"],
      "RTV Ljubljana" => ["LD", "LP", "SD", "SP"],
      "Helidon" => ["FLP-04", "FLP-05", "FLP-09", "FSP-5"], # TODO
      "Sarajevo Disk" => ["LP", "SB", "SBK"],
      "Studio B" => ["SE", "SP"]
    }
    labels.each do |label, prefixes|
      print "#{label}".on_red
      print "\n\n"
      prefixes.each do |prefix|
        catnums = Album.original.where(label: label).where("catnum LIKE ?", "#{prefix}-%").pluck(:catnum)
        catnums = catnums.flat_map{|c| c.split(";")}.uniq.map{|c| c.gsub("#{prefix}-", "").to_i}.uniq.sort
        prefix_estimated_total = catnums.count
        catnums.each.with_index do |catnum, i|
          print "#{prefix}-#{catnum}  ".green
          next if i + 1 >= catnums.count
          diff = catnums[i + 1] - catnum - 1
          if diff < 19
            prefix_estimated_total += diff
            diff.times { |d| print "#{prefix}-#{catnum + d + 1}  ".yellow }
          else
            print "\n"
          end
        end
        total += catnums.count
        estimated_total += prefix_estimated_total
        print "Collected #{catnums.count}/#{prefix_estimated_total} (#{(100.0 * catnums.count / prefix_estimated_total).round(2)}%)".on_blue
        print "\n\n"
      end
    end

    print "\n\n"
    print "TOTAL: #{total}/#{estimated_total} (#{(100.0 * total / estimated_total).round(2)}%)".on_blue
    print "\n"
  end

end
