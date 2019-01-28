# frozen_string_literal: true

module Departments
  module Demo
    module Shared
      ##
      # Holds constants ([ENUM]s) for identifying [CyberReport] specific type.
      module AnalysisType
        ICMP_DOS_CYBER_REPORT = 'icmp_dos_cyber_report'

        def self.dos_formats
          result = []
          result << ICMP_DOS_CYBER_REPORT
          result
        end
      end
    end
  end
end
