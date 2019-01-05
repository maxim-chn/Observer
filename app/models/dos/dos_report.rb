module Dos
  class DosReport < CyberReport
    self.abstract_class = true
    # ##################################################
    # Enums related to Holt Winters algorithm
    FIRST_SEASONAL_INDEX                    = 0
    SEASON_DURATION_IN_SECONDS              = 24 * 60 * 60 # 24 hours * 60 minutes * 60 seconds
    INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS = 10           # Every 10 seconds, we collect amount of ICMP requests
                                                           # from friendly resource
    # ##################################################
    # ##################################################
    # Enums related to cyber report types
    ICMP_DOS_CYBER_REPORT = 'icmpDosCyberReport'
    # ##################################################
  end # DosReport
end # Dos
