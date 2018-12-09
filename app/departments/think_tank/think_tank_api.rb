require 'singleton'
require_relative '../intelligence/intelligence_api.rb'
require_relative '../shared/intelligence_collect_status.rb'
require_relative '../shared/intelligence_format.rb'
require_relative '../shared/intelligence_query.rb'

module Departments
  module ThinkTank
    class ThinkTankApi

      include Singleton

      def monitorDos(friendlyResourceId)
        friendlyResource   = FriendlyResource.find(friendlyResourceId)
        intelligenceQuery  = Departments::Shared::IntelligenceQuery.new(
          friendlyResource.ip_address(),
          Departments::Shared::IntelligenceCollectStatus::COLLECT,
          Departments::Shared::IntelligenceFormat::DOS
        )
        intelligenceDepartment = Departments::Intelligence::IntelligenceApi.instance()
        Rails.logger.debug("ThinkTankApi - monitorDos() - IntelligenceQuery - #{intelligenceQuery.inspect()}")
        intelligenceDepartment.startIntelligenceGathering(intelligenceQuery)
      end

      def stopMonitoring(friendlyResourceId)
        friendlyResource   = FriendlyResource.find(friendlyResourceId)
        intelligenceQuery  = Departments::Shared::IntelligenceQuery.new(
          friendlyResource.ip_address(),
          Departments::Shared::IntelligenceCollectStatus::NOT_COLLECT
        )
        intelligenceDepartment = Departments::Intelligence::IntelligenceApi.instance()
        Rails.logger.debug("ThinkTankApi - stopMonitoringDos() - IntelligenceQuery - #{intelligenceQuery.inspect()}")
        intelligenceDepartment.startIntelligenceGathering(intelligenceQuery)
      end

    end # ThinkTankApi
  end # ThinTank
end # Departments