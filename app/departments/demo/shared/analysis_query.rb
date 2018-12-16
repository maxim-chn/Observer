module Departments
  module Demo
    module Shared
      class AnalysisQuery
        attr_reader :friendlyResourceId, :friendlyResourceIp, :analysisType
        
        def initialize(friendlyResourceId, friendlyResourceIp, analysisType)
          @friendlyResourceId = friendlyResourceId
          @friendlyResourceIp = friendlyResourceIp
          @analysisType       = analysisType
        end
        
        def inspect()
          "friendlyResourceId: #{@friendlyResourceId}, friendlyResourceIp: #{@friendlyResourceIp}, analysisFormat: #{@analysisType}"
        end
        
      end # AnalysisQuery
    end # Shared
  end # Demo
end # Departments