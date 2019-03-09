# frozen_string_literal: true

# Scopes classes that represent DOS related data.
# For example, {Dos::IcmpFloodReport}.
module Dos
  ##
  # Any class that represents DOS interpretation data should extend this class.
  # This is an abstract class.
  class DosReport < CyberReport
    self.abstract_class = true
    # Enums related to Holt Winters algorithm.
    HOURS_IN_A_DAY = 24
    MINUTES_IN_AN_HOUR = 60
    SECONDS_IN_A_MINUTE = 60
    SEASON_DURATION_IN_SECONDS = (HOURS_IN_A_DAY * MINUTES_IN_AN_HOUR * SECONDS_IN_A_MINUTE)
    # Every 10 seconds, we collect amount of ICMP requests from friendly resource
    INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS = 10
    FIRST_SEASONAL_INDEX = 0
    LAST_SEASONAL_INDEX = SEASON_DURATION_IN_SECONDS / INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS - 1
  end
end
