module Departments
  module Demo
    module Shared
      class IntelligenceQuery
        attr_reader :friendlyResourceIp, :collectFormat
        
        def initialize(friendlyResourceIp, collectFormat)
          @friendlyResourceIp      = friendlyResourceIp
          @collectFormat = collectFormat
        end
  
        def inspect()
          "friendlyResourceIp: #{@friendlyResourceIp}, collectFormat: #{@collectFormat}"
        end
        
      end # IntelligenceQuery
    end # Shared
  end # Demo
end # Departments