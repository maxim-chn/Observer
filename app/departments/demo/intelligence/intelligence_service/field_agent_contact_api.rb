require 'singleton'

module Departments
  module Demo
    module Intelligence
      module IntelligenceService
        class FieldAgentContactApi  
          include Singleton
  
          def missionDispatch(intelligenceQuery)
            Rails.logger.info("FieldAgentContactApi - missionDispatch() - intelligenceQuery : #{intelligenceQuery.inspect()}")
            Workers::Demo::Intelligence::AddCollectionFormat.perform_async(
              intelligenceQuery.friendlyResourceIp, intelligenceQuery.collectFormat
            )
          end
          def missionAbort(intelligenceQuery)
            Rails.logger.info("FieldAgentContactApi - missionAbort() - intelligenceQuery : #{intelligenceQuery.inspect()}")
            Workers::Demo::Intelligence::RemoveCollectionFormat.perform_async(
              intelligenceQuery.friendlyResourceIp, intelligenceQuery.collectFormat
            )
          end
        end # FieldAgentContactApi
      end # IntelligenceServices
    end # Intelligence
  end # Demo
end # Departments