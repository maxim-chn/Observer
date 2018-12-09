module Departments
  module Shared
    class IntelligenceQuery
      attr_reader :targetIp, :collectStatus, :collectFormat
      def initialize(targetIp, collectStatus, collectFormat=nil)
        @targetIp      = targetIp
        @collectStatus = collectStatus
        @collectFormat = collectFormat
      end

      def inspect()
        "targetIp: #{targetIp}, collectStatus: #{collectStatus}, collectFormat: #{collectFormat}"
      end
    end # IntelligenceQuery
  end # Shared
end # Departments