module Departments
  module Demo
    module Shared
      module AnalysisType
        ICMP_DOS_CYBER_REPORT = "icmpDosCyberReport"
        def self.getDosFormats()
          result = []
          result << ICMP_DOS_CYBER_REPORT
          return result
        end
      end # AnalysisType
    end # Shared
  end # Demo
end # Departments