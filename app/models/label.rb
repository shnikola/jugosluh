class Label

  def self.major
    Label::MAJOR_LABEL_PREFIXES.keys
  end

  def self.major?(label)
    major.include?(normalize(label))
  end

  def self.normalize(label)
    ALIASES[label.downcase] || major.find{|l| label.casecmp(l).zero? } || label
  end

  def self.foreign_series?(label, catnum)
    prefixes = Label::MAJOR_LABEL_PREFIXES.dig(label, :foreign)
    prefixes.present? ? prefixes.any?{|p| prefix_match?(p, catnum) } : false
  end

  def self.domestic_series?(label, catnum)
    prefixes = Label::MAJOR_LABEL_PREFIXES.dig(label, :domestic)
    prefixes.present? ? prefixes.any?{|p| prefix_match?(p, catnum) } : false
  end

  def self.prefix_match?(prefix, catnum)
    prefix.is_a?(Regexp) ? (catnum =~ prefix) : catnum.start_with?(prefix)
  end

  ALIASES = {
    'zkp rtvl' => "RTV Ljubljana",
    'rtb' => "PGP RTB"
  }

  MAJOR_LABEL_PREFIXES = {
    "Jugoton" => {
      domestic: [
        "F-",                  # Flexi 1964-1976
        "R-",                  # Flexi: Zvuci Domovine 1964-1965
        /^J-\d{4}/,            # Singles 1947-1952
        "C-",                  # Singles 1950-1959
        /^SY-[12]/,            # Singles, 1958-1989
        "SVY-",                # Singles: Studio, 1972
        "MCY-",                # Singles, Gusle 1963-1974
        "S-2-EPP-", "S-22",    # Singles: Promo 1990-1991
        "EPY-",                # EPS 1958-1987
        "LPY", "LPSVY", "LPSY",
        "LPVS", "LPVY",        # LPS 1957-1975
        "LSY-10", "LSY-6",     # LPS 1970-1990 (LSY-65 and -66 have a few foreign jazz ones)
        /^LP-6[12]/,           # LPS 1988-1991
        /^J-\d{1,2}\W/,        # Singles, Compilations 1970-1982
        /JEX-/,                # LPS: Jugoton Express 1982-1987
        "CAY-",                # Cassettes 1971-1989
        "MC-6-S-", "MC-63",    # Cassettes 1989-1991
        "CD-",                 # CDs 1990-1991
      ],
      mixed: [
        "LPM-",       # LPS: Various 1956-1961
        "UCAY-",      # Cassettes: Other Studios 1973-1988
        "UEP-",       # EPS: Other Studios 1963-1989
        "ULP", "ULS", # LPS: Other Studios 1966-1989
        "USD-",       # Singles: Other Studios 1969-1989
        "U-",         # Cassettes: Religous and Random 1990-1991
        /^V[FKM]-/,   # VHS, 1987-1990
      ],
      foreign: [
        /^CA[A-W]/, # Cassettes
        /^EP[A-W]/, # EPS
        /^LP-7[12]/, # LPS
        /^LP[A-HP-RT]/, /^LPS[A-U]/,
        /^LPSV[A-W]/, "LQ",
        /^LS[A-UW]/, /^LSV[DI-Z]/,
        "MC-7", # Cassettes
        "MXS", # Maxi Singles
        /^S[A-UW]/, /^SV[A-I]/, # Singles
      ]
    },

    "PGP RTB" => { # TODO
      #   catnum =~ /(^111)|(^112)|(^15)|(^20)|(^21)|(^23)|(^31)|(^40)|(^41)|(^50)|(^51)|(^80)|(^EP-1)|(^EP-50)|(^EP-6)|(^LP-1)|(^LP-6)|(^NK-)|(^S-1)|(^S-51)|(^S-52)|(^S-6)|(^SF-)/
      # https://rateyourmusic.com/list/RockyRock369
      domestic: [],
      foreign: []
    },

    "Diskos" => {
      domestic: [
        /^NDKF?-[1-9]/, # Singles 1962-1988
        "MDK-",         # Singles/EPS: Literature, Gusle 1961-1978
        /^EDK-[3-9]/,   # EPS 1962-1981
        "LPD-",         # LPS 1975-1991
        "KD-",          # Cassettes 1975-1991
        "VKD-"          # VHS 1988-1991
      ],
      foreign: [
        "EDK-0", # EPS
        "KS-",   # Cassettes
        "LPL-",  # LPS
        "NDK-0"  # Singles
      ]
    },

    "Suzy" => {
      domestic: [
        "EP-", # EPs 1973-1990
        "KS-", # Casettes 1975-1990
        "LP-", # LPs 1972-1991
        "SP-", # Singles 1972-1990
        "VK-", # VHS 1989
      ],
      mixed: [
        "K-"
      ],
      foreign: [
        "DEF-", "ELK-", "EMB-",
        "EPC-", "GEF-", "JET",
        "MCA-", "MID-", "MNT-",
        "PIR-", "PRT-", "Q-",
        "RAD-", "REP-", "RS-",
        "S-", "SIR-", "SKY-",
        "SS", "WB-", "WEA-", "YB-"
      ]
    },

    "RTV Ljubljana" => {
      domestic: [
        "KD-", # Casettes 1970-1990
        "LP-", # LPS 1973-1976
        "LD-", # LPS 1977-1990
        "SP-", # Singles 1973-1976
        "SD-", # Singles 1976-1985
        "VD-", # VHS 1988-1990
      ],
      foreign: [
        "KL-", # Cassettes
        "LPL-", "LL-", # LPs
        "SPL-", "SL-", # Singles
      ]
    },

    "Diskoton" => {
      domestic: [
        "SN-",     # Singles: Narodna 1973-1983
        "SZ-",     # Singles: Zabavna 1973-1983
        "LP-",     # LPS 1973-1991
        "DTK-",    # Cassettes 1975-1991
        "DCD-",    # CDS 1990-1991
        "VIDI-"    # VHS 1989-1991
      ],
      foreign: [
        "DKL-",  # Cassettes
        "LPL-",  # LPS
        "SZL-",  # Singles
      ]
    },

    "Beograd Disk" => {
      domestic: [
        "SBK-0",  # Singles: Narodna 1970-1981
        "SVK-",   # Singles: Zabavna 1969-1981
        "K-",     # Singles: Children 1971-1972
        "SBR-",   # Singles: Boris Bizetić 1977
        "EBK-",   # EPS: Narodna 1968-1978
        "EHK-",   # EPS: Humor 1968
        "ESK-",   # ESK: Religiozna 1968
        "EVK-",   # EPS: Zabavna 1968-1972
        "MŠS-",   # EPS: Mali Šlager Sezone 1972
        "KEK-",   # EPS 1972
        "LPD-",   # LPS 1978-1980
        "BDN-",   # Cassettes 1978-1982
      ],
      foreign: [
        "BDS-",  # Cassettes
        "LPS-",  # LPS
        "SBK-6", "SBKS", # Singles
        "SVKS", # Singles
      ]
    },

    "Jugodisk" => {
      domestic: [
        "BDN-", # Cassettes 1982-1991
        "JDN-", # Singles 1981-1982
        "LPD-", # LPS 1980-1991
        "SVK-", # Singles 1981-1982
        "YUV-", # VHS 1989-1991
      ],
      foreign: [
        "BDS-", # Cassettes
        "LPS-", # LPS
        "SVKS-", # Singles
      ]
    },

    "Helidon" => {
      domestic: [
        "6.15", # Cassettes 1989-1991
        "6.55", # LPS 1989-1991
        "6.75", # CDS 1989-1991
        "FEP-", "EP-", # EPS 1969-1973
        "LP-", # LPS 1968-1970
        "FLP-", # LPS 1969-1989
        "FSP-", # Singles 1969-1986
        "SP-", # Singles 1968-1974
        "SVY-", # Singles 1972
        "UFLP-", # LPS 1971-1980
        "USP-", # SP 1968-1980
      ],
      mixed: [
        "K-" # Cassettes
      ],
      foreign: [
        "6.11", "6.12", # Singles
        "6.2", # LPS
        "7.", # LPS
        "AC-", "D-", # Singles
        "KL-", # Cassettes
        "LL-", # LPS,
        "SLE", "SLK", # LPS
        "U-", # Singles
      ]
    },

    "Sarajevo Disk" => {
      domestic: [
        "LP-",  # LPS 1980-1990
        "SB-",  # Singles 1979-1983
        "SBK-", # Cassettes 1980-1991
        "SDZ-", # Singles 1979
      ],
      foreign: [
        "KBG-",  # Cassettes
        "LBG-",  # LPS
      ]
    },

    "Studio B" => {
      domestic: [
        "SE-", # EPS 1973-1975
        "SP-", # Singles 1973-1976
      ],
      foreign: [
        "7-N",
        "GH-",
      ]
    },

    "Sportska Knjiga" => {
      domestic: [
        /^\d{2}$/,  # Flexi 1960
        "ESK-3",    # EPs 1968-1969
      ],
      foreign: [
        "ESK-0", # EPS
      ]
    },

    "Šumadija" => {
      domestic: [
        "EP-", # EPS 1970-1972
        "NP-", # Singles 1970-1972
      ]
    },

    "FV Založba" => {
      domestic: [
        "FV-",    # Albums and stuff
        "ZKFV-",  # Cassettes, Live 1986-1990
      ]
    },

    "Vojvodinakoncert" => {
      domestic: [
        "KD-",        # Cassettes 1983-1987
        "LD-", "LP-", # LPs 1983-1989
        "SD-",        # Singles 1986
        "UEP-",       # EPs 1989
      ]
    },

    "PGP Radio Kruševac" => {
      domestic: [
        "RKA-", # Singles 1972-1973
        "RKB-", # EPs 1972-1973
        "RKC-", # Singles 1972-1973
        "RKE-", # EPs 1972-1973,
        "RKN-", # Singles 1972
        "RKS-", # Singles 1972
      ]
    },
  }

end
