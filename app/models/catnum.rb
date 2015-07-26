module Catnum
  
  def self.guess(line)
    return if line.blank?
    line = line.gsub("\u200E", "")
   
    if line =~ /Jugoton/i
      catnum = line.match(/Jugoton[\s–,-]+(?:Zagreb[\s–,-]+)?(?:LP )?(\w+[\s–-]*(?:S )?(?:-?\w)+)/i).try(:[],1)
    elsif line =~ /Beograd Disk/i
      catnum = line.match(/Beograd Disk(?:o|-a)?[\s,–-]+(\w+[\s–-]*\w?[\s–-]*\d+)/i).try(:[], 1)
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
    elsif line =~ /RTB/i
      catnum = line.match(/(?:PGP[ -])?(?:RTB|S)(?:[\s–-]+PGP)?(?:[\s,–-]+Beograd)?[\s–,-]*(\w*(?:[\s–-]+I+)?(?:[\s–-]+[\d]+)+)/i).try(:[], 1)
    end
    
    normalize(catnum) if catnum.present?
  end
  
  def self.normalize(catnum)
    catnum.strip.gsub(/[\s-]+/, "-").to_lat.upcase
  end
  
  def self.next(catnum)
    number = catnum.scan(/\d+/).last
    return nil if number.nil?
    next_number = (number.to_i + 1).to_s.rjust(number.to_s.length, "0")
    catnum.reverse.gsub(number.reverse, next_number.reverse).reverse # Replace last occurence
  end
end