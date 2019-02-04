# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Holds Enum objects for identifying intelligence data specific type.
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
