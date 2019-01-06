module Departments
  module Demo
    module Shared
      module IntelligenceFormat
        DOS_ICMP = "DOS_ICMP"
        def self.getDosFormats()
          result = []
          result << DOS_ICMP
          return result
        end
      end # IntelligenceFormat
    end # Shared
  end # Demo
end # Departments