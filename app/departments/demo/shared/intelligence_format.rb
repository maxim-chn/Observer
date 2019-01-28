# frozen_string_literal: true

module Departments
  module Demo
    module Shared
      ##
      # Holds constants ([ENUM]s) for identifying intelligence data specific type.
      module IntelligenceFormat
        DOS_ICMP = 'dos_icmp'

        def self.dos_formats
          result = []
          result << DOS_ICMP
          result
        end
      end
    end
  end
end
