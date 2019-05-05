# frozen_string_literal: true

module Departments
  module Shared
    ##
    # Holds the Enum objects for identifying the {CyberReport} type.
    module AnalysisType
      ICMP_DOS_CYBER_REPORT = 'icmp_dos_cyber_report'
      SQL_INJECTION_CYBER_REPORT = 'sql_injection_report'

      # Collection of the available {https://en.wikipedia.org/wiki/Denial_of_Service_attack DOS} {CyberReport} types.
      # @return [Array<String>]
      def self.dos_formats
        result = []
        result << ICMP_DOS_CYBER_REPORT
        result
      end

      # Collection of the available {https://en.wikipedia.org/wiki/Code_injection Code Injection} {CyberReport} types.
      # @return [Array<String>]
      def self.code_injection_formats
        result = []
        result << SQL_INJECTION_CYBER_REPORT
        result
      end

      # Collection of all the possible {CyberReport} types.
      # @return [Array<String>]
      def self.formats
        dos_formats + code_injection_formats
      end
    end
  end
end
