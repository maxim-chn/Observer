module Departments
  module Demo
    module Shared
      class IntelligenceQuery
        attr_reader :friendlyResourceIp, :collectFormat
        def initialize(friendlyResourceIp, collectFormat)
          @friendlyResourceIp      = friendlyResourceIp
          @collectFormat           = collectFormat
        end
        def inspect()
          result = {}
          result[:friendlyResourceIp] = @friendlyResourceIp
          result[:collectFormat]      = @collectFormat
          JSON.generate(result)
        end
      end # IntelligenceQuery
    end # Shared
  end # Demo
end # Departments