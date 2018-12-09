require 'singleton'

module Departments
  module Intelligence
    module IntelligenceServices
      class FieldAgentContactApi

        include Singleton

        def missionDispatch(intelligenceQuery)
          FieldAgentNotifier.perform_async(
            intelligenceQuery.targetIp, intelligenceQuery.collectStatus, intelligenceQuery.collectFormat
          )
        end

        def missionAbort(intelligenceQuery)
          FieldAgentNotifier.perform_async(intelligenceQuery.targetIp, intelligenceQuery.collectStatus, nil)
        end

      end # FieldAgentContactApi
    end # IntelligenceServices
  end # Intelligence
end # Departments