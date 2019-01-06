require 'singleton'
require_relative './intelligence_services/services.rb'
module Departments
  module Demo
    module Intelligence
      class Api
        include Singleton
        def startIntelligenceGathering(intelligenceQuery)
          Rails.logger.info("#{self.class.name} - #{__method__} - intelligenceQuery : #{intelligenceQuery.inspect()}")
          fieldAgentContactApi = Departments::Demo::Intelligence::IntelligenceServices::FieldAgentContact::Api.instance()
          fieldAgentContactApi.missionDispatch(intelligenceQuery)
        end  
        def stopIntelligenceGathering(intelligenceQuery)
          Rails.logger.info("#{self.class.name} - #{__method__} - intelligenceQuery : #{intelligenceQuery.inspect()}")
          fieldAgentContactApi = Departments::Demo::Intelligence::IntelligenceServices::FieldAgentContact::Api.instance()
          fieldAgentContactApi.missionAbort(intelligenceQuery)
        end
      end # Api
    end # Intelligence
  end # Demo
end # Departments