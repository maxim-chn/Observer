module Departments
  module Demo
    module Shared
      class AnalysisQuery
        attr_reader :friendlyResourceIp, :analysisType
        def initialize(friendlyResourceIp, analysisType)
          @friendlyResourceIp = friendlyResourceIp
          @analysisType       = analysisType
        end
        def inspect()
          result = {}
          result[:friendlyResourceIp] = @friendlyResourceIp
          result[:analysisType]       = @analysisType
          return JSON.generate(result)
        end
      end # AnalysisQuery
    end # Shared
  end # Demo
end # Departments