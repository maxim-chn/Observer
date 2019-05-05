# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Holds the Enum objects for identifying the intelligence type.
    module IntelligenceFormat
      ICMP_DOS_CYBER_REPORT = 'icmp_dos_cyber_report'
      SQL_INJECTION_CYBER_REPORT = 'sql_injection_report'

      # Collection of the available {https://en.wikipedia.org/wiki/Denial_of_Service_attack DOS} intelligence types.
      # @return [Array<String>]
      def self.dos_formats
        result = []
        result << ICMP_DOS_CYBER_REPORT
        result
      end

      # Collection of the available {https://en.wikipedia.org/wiki/Code_injection Code Injection} intelligence types.
      # @return [Array<String>]
      def self.code_injection_formats
        result = []
        result << SQL_INJECTION_CYBER_REPORT
        result
      end

      # Collection of all possible intelligence formats.
      # @return [Array<String>]
      def self.formats
        dos_formats + code_injection_formats
      end
    end
  end
end
