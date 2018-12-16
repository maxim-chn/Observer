require 'singleton'
require_relative './think_tank_service/think_tank_service'

module Departments
  module Demo
    module ThinkTank
      class ThinkTankApi
        include Singleton

        def startMonitoring(friendlyResourceId)
          Rails.logger.info("ThinkTankApi - startMonitoring() - friendlyResourceId : #{friendlyResourceId}")
          archiveApi       = Departments::Demo::Archive::ArchiveApi.instance()
          friendlyResource = archiveApi.getFriendlyResourceById(friendlyResourceId)
          thinkTankService = Departments::Demo::ThinkTank::ThinkTankService.instance()
          # Dos related methods.
          thinkTankService.gatherDosIntelligence(friendlyResource.id(), friendlyResource.ip_address())
          thinkTankService.analyzeDosIntelligence(friendlyResource.id(), friendlyResource.ip_address())
        end
        def stopMonitoring(friendlyResourceId)
          Rails.logger.info("ThinkTankApi - stopMonitoring() - friendlyResourceId : #{friendlyResourceId}")
          archiveApi       = Departments::Demo::Archive::ArchiveApi.instance()
          friendlyResource = archiveApi.getFriendlyResourceById(friendlyResourceId)
          friendlyResource = FriendlyResource.find(friendlyResourceId)
          thinkTankService = Departments::Demo::ThinkTank::ThinkTankService.instance()
          # Dos related methods.
          thinkTankService.stopDosIntelligenceGathering(friendlyResource.id(), friendlyResource.ip_address())
          thinkTankService.stopDosIntelligenceAnalysis(friendlyResource.id(), friendlyResource.ip_address())
        end
      end # ThinkTankApi
    end # ThinTank
  end # Demo
end # Departments