class Label

  def self.major
    ["Jugoton", "PGP RTB", "Diskos", "Diskoton", "Beograd Disk", "Jugodisk", "RTV Ljubljana", "Helidon", "Sarajevo Disk", "Studio B"]
  end

  def self.major?(label)
    major.include?(normalize(label))
  end

  def self.normalize(label)
    {'zkp rtvl' => "RTV Ljubljana"}[label.downcase] || label
  end

  CATNUM_PREFIXES = {
    # TODO
  }

end
