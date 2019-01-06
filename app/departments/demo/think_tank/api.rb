require 'singleton'
require_relative './think_tank_services/services'
module Departments
  module Demo
    module ThinkTank
      class Api
        include Singleton
        def startMonitoring(friendlyResourceId)
          Rails.logger.info("#{self.class.name} - #{__method__} - friendlyResourceId : #{friendlyResourceId}")
          thinkTankServices = Departments::Demo::ThinkTank::ThinkTankServices::Services.instance()
          friendlyResource  = thinkTankServices.getFriendlyResourceById(friendlyResourceId)
          # Dos related methods.
          thinkTankServices.gatherDosIntelligence(friendlyResource.ip_address())
          thinkTankServices.analyzeDosIntelligence(friendlyResource.ip_address())
        end
        def stopMonitoring(friendlyResourceId)
          Rails.logger.info("#{self.class.name} - #{__method__} - friendlyResourceId : #{friendlyResourceId}")
          thinkTankServices = Departments::Demo::ThinkTank::ThinkTankServices::Services.instance()
          friendlyResource  = thinkTankServices.getFriendlyResourceById(friendlyResourceId)
          # Dos related methods.
          thinkTankServices.stopDosIntelligenceGathering(friendlyResource.ip_address())
          thinkTankServices.stopDosIntelligenceAnalysis(friendlyResource.ip_address())
        end
      end # ThinkTankApi
    end # ThinTank
  end # Demo
end # Departments