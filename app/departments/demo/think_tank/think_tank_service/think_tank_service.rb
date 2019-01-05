require 'singleton'

module Departments
  module Demo
    module ThinkTank
      class ThinkTankService
        include Singleton
        # ##################################################
        # Intelligence related methods.
        # ##################################################
        def gatherDosIntelligence(friendlyResourceId, friendlyResourceIpAddress)
          Rails.logger.info("ThinkTankService - gatherDosIntelligence() - friendlyResource - id: #{friendlyResourceId}, ip : #{friendlyResourceIpAddress}")
          intelligenceQuery = Departments::Demo::Shared::IntelligenceQuery.new(
            friendlyResourceIpAddress, Departments::Demo::Shared::IntelligenceFormat::DOS
          )
          intelligenceDepartment = Departments::Demo::Intelligence::IntelligenceApi.instance()
          intelligenceDepartment.startIntelligenceGathering(intelligenceQuery)
        end
        def stopDosIntelligenceGathering(friendlyResourceId, friendlyResourceIpAddress)
          Rails.logger.info("ThinkTankService - stopIntelligenceGathering() - friendlyResource - id: #{friendlyResourceId}, ip : #{friendlyResourceIpAddress}")
          intelligenceQuery = Departments::Demo::Shared::IntelligenceQuery.new(
            friendlyResourceIpAddress, Departments::Demo::Shared::IntelligenceFormat::DOS
          )
          intelligenceDepartment = Departments::Demo::Intelligence::IntelligenceApi.instance()
          intelligenceDepartment.stopIntelligenceGathering(intelligenceQuery)
        end
        # ##################################################
        # Analysis related methods.
        # ##################################################
        def analyzeDosIntelligence(friendlyResourceId, friendlyResourceIpAddress)
          Rails.logger.info("ThinkTankService - analyseDosIntelligence() - friendlyResource - id: #{friendlyResourceId}, ip : #{friendlyResourceIpAddress}")
          analysisQuery = Departments::Demo::Shared::AnalysisQuery.new(
            friendlyResourceId, friendlyResourceIpAddress, Departments::Demo::Shared::AnalysisType::DOS
          )
          analysisDepartment = Departments::Demo::Analysis::AnalysisApi.instance()
          analysisDepartment.produceDosInterpretationData(analysisQuery)
          end
        def stopDosIntelligenceAnalysis(friendlyResourceId, friendlyResourceIpAddress)
          Rails.logger.info("ThinkTankService - stopDosIntelligenceAnalysis() - friendlyResource - id: #{friendlyResourceId}, ip : #{friendlyResourceIpAddress}")
          analysisQuery = Departments::Demo::Shared::AnalysisQuery.new(
            friendlyResourceId, friendlyResourceIpAddress, Departments::Demo::Shared::AnalysisType::DOS
          )
          analysisDepartment = Departments::Demo::Analysis::AnalysisApi.instance()
          analysisDepartment.stopDosInterpretationDataProduction(analysisQuery)
        end
      end # ThinkTankServices
    end # ThinkTank
  end # Demo
end # Departments