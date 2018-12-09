require 'singleton'
require_relative './intelligence_services/field_agent_contact_api.rb'

module Departments
  module Intelligence
    class IntelligenceApi

      include Singleton

      def startIntelligenceGathering(intelligenceQuery)
        fieldAgentContact = Departments::Intelligence::IntelligenceServices::FieldAgentContactApi.instance()
        fieldAgentContact.missionDispatch(intelligenceQuery)
      end

      def stopIntelligenceGathering(intelligenceQuery)
        fieldAgentContact = Departments::Intelligence::IntelligenceServices::FieldAgentContactApi.instance()
        fieldAgentContact.missionAbort(intelligenceQuery)
      end

    end # IntelligenceApi
  end # Intelligence
end # Departments