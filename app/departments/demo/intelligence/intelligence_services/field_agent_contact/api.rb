require 'singleton'
module Departments
  module Demo
    module Intelligence
      module IntelligenceServices
        module FieldAgentContact
          class Api  
            include Singleton
            def missionDispatch(intelligenceQuery)
              Rails.logger.info("#{self.class.name} - #{__method__} - intelligenceQuery : #{intelligenceQuery.inspect()}")
              Workers::Demo::Intelligence::AddCollectionFormat.perform_async(
                intelligenceQuery.friendlyResourceIp, intelligenceQuery.collectFormat
              )
            end
            def missionAbort(intelligenceQuery)
              Rails.logger.info("#{self.class.name} - #{__method__} - intelligenceQuery : #{intelligenceQuery.inspect()}")
              Workers::Demo::Intelligence::RemoveCollectionFormat.perform_async(
                intelligenceQuery.friendlyResourceIp, intelligenceQuery.collectFormat
              )
            end
          end # Api
        end # FieldAgentContact
      end # IntelligenceServices
    end # Intelligence
  end # Demo
end # Departments