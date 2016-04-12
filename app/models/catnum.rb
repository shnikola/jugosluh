module Catnum

  def self.guess(line)
    return if line.blank?
    line = line.squish.gsub("\u200E", "")

    if line =~ /Jugoton/i
      catnum = line.match(/Jugoton[\s–,-]+(?:Zagreb[\s–,-]+)?(?:LP )?(\w+[\s–-]*(?:S )?(?:-?\w)+)/i).try(:[], 1)
    elsif line =~ /Beograd Disk/i
      catnum = line.match(/Beograd Disk(?:o|-a)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Sarajevo Disk/i
      catnum = line.match(/Sarajevo Disk[\s,–-]+(\w+[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Jugodisk/i
      catnum = line.match(/Jugodisk(?:o|-a)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Diskoton/i
      catnum = line.match(/Diskoton(?:[\s,–-]+Sarajevo)?(?:[\s,–-]+DT)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Diskos/i
      catnum = line.match(/Diskos[\s,–-]+(\w+[\sF–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Helidon/i
      catnum = line.match(/Helidon[\s,–-]+(\w+[\s–-]*(?:[\s\.-]*\d+)+)/i).try(:[], 1)
    elsif line =~ /Suzy/i
      catnum = line.match(/Suzy(?:[\s,–-]+Zagreb)?(?:[\s,–-]+records)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Studio B/i
      catnum = line.match(/Studio B[\s,–-]+(\w+[\d\s–-]+)/i).try(:[], 1)
    elsif line =~ /RTB/i
      catnum = line.match(/(?:PGP[ -])?(?:RTB|S)(?:[\s–-]+PGP)?(?:[\s,–-]+Beograd)?[\s–,-]*(\w*(?:[\s–-]+I+)?(?:[\s–-]+[\d]+)+)/i).try(:[], 1)
    elsif line =~ /RTVL/i || line =~ /Ljubljana/i
      catnum = line.match(/RTV?L?J?[\s,–-]*(?:Ljubljana)?[\s,–-]+([KLS][DP][\s–-]*\d+)/i).try(:[], 1)
    elsif line =~ /Krusevac/i
      catnum = line.match(/Krusevac[\s,–-]+(\w+[\s–-]*\d+)/i).try(:[], 1)
    end

    normalize(catnum) if catnum.present?
  end

  def self.normalize(catnum)
    clean = catnum.to_lat.upcase.gsub(/[\s–-]+/, "")
    return catnum if clean.blank?
    # Group together letters and numbers
    split = clean.scan(/\p{Alpha}+|\p{Digit}+|[^\p{Alpha}\p{Digit}]+/u)
    grouped = split.inject{|total, s| total.last =~ /\p{Alpha}|\p{Digit}/u && s.first =~ /\p{Alpha}|\p{Digit}/u ? "#{total}-#{s}" : "#{total}#{s}"}
    grouped.gsub(/-F$/, "") # Remove -F from end
  end

end
