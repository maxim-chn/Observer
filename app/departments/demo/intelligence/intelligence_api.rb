require 'singleton'
require_relative './intelligence_service/field_agent_contact_api.rb'

module Departments
  module Demo
    module Intelligence
      class IntelligenceApi
        include Singleton
  
        def startIntelligenceGathering(intelligenceQuery)
          Rails.logger.info("IntelligenceApi - startIntelligenceGathering() - intelligenceQuery : #{intelligenceQuery.inspect()}")
          fieldAgentContact = Departments::Demo::Intelligence::IntelligenceService::FieldAgentContactApi.instance()
          fieldAgentContact.missionDispatch(intelligenceQuery)
        end  
        def stopIntelligenceGathering(intelligenceQuery)
          Rails.logger.info("IntelligenceApi - stopIntelligenceGathering() - intelligenceQuery : #{intelligenceQuery.inspect()}")
          fieldAgentContact = Departments::Demo::Intelligence::IntelligenceService::FieldAgentContactApi.instance()
          fieldAgentContact.missionAbort(intelligenceQuery)
        end
  
      end # IntelligenceApi
    end # Intelligence
  end # Demo
end # Departments