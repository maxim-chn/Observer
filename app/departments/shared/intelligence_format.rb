# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Holds Enum objects for identifying intelligence type.
    module IntelligenceFormat
      ICMP_DOS_CYBER_REPORT = 'icmp_dos_cyber_report'

      # Collection of available intelligence types
      # @return [Array<String>]
      def self.dos_formats
        result = []
        result << ICMP_DOS_CYBER_REPORT
        result
      end

      # Collection of all possible intelligence formats.
      # @return [Array<String>]
      def self.formats
        dos_formats
      end
    end
  end
end
