require 'singleton'

module Departments
  module Demo
    module ThinkTank
      module ThinkTankServices
        class Services
          include Singleton
          # ##################################################
          # Intelligence related methods.
          # ##################################################
          def gatherDosIntelligence(friendlyResourceIp)
            Rails.logger.info("#{self.class.name} - #{__method__} - friendlyResource - ip : #{friendlyResourceIp}")
            intelligenceDepartment = Departments::Demo::Intelligence::Api.instance()
            Departments::Demo::Shared::IntelligenceFormat.getDosFormats().each do |intelligenceFormat|
              intelligenceQuery = Departments::Demo::Shared::IntelligenceQuery.new(friendlyResourceIp, intelligenceFormat)
              intelligenceDepartment.startIntelligenceGathering(intelligenceQuery)
            end
          end
          def stopDosIntelligenceGathering(friendlyResourceIp)
            Rails.logger.info("#{self.class.name} - #{__method__} - friendlyResource - ip : #{friendlyResourceIp}")
            intelligenceDepartment = Departments::Demo::Intelligence::Api.instance()
            Departments::Demo::Shared::IntelligenceFormat.getDosFormats().each do |intelligenceFormat|
              intelligenceQuery = Departments::Demo::Shared::IntelligenceQuery.new(friendlyResourceIp, intelligenceFormat)
              intelligenceDepartment.stopIntelligenceGathering(intelligenceQuery)
            end
          end
          # ##################################################
          # Analysis related methods.
          # ##################################################
          def analyzeDosIntelligence(friendlyResourceIp)
            Rails.logger.info("#{self.class.name} - #{__method__} - friendlyResource - ip : #{friendlyResourceIp}")
            analysisDepartment = Departments::Demo::Analysis::Api.instance()
            Departments::Demo::Shared::AnalysisType.getDosFormats().each do |analysisFormat|
              analysisQuery = Departments::Demo::Shared::AnalysisQuery.new(friendlyResourceIp, analysisFormat)
              analysisDepartment.produceInterpretationData(analysisQuery)
            end
            end
          def stopDosIntelligenceAnalysis(friendlyResourceIp)
            Rails.logger.info("#{self.class.name} - #{__method__} - friendlyResource - ip : #{friendlyResourceIp}")
            analysisDepartment = Departments::Demo::Analysis::Api.instance()
            Departments::Demo::Shared::AnalysisType.getDosFormats().each do |analysisFormat|
              analysisQuery = Departments::Demo::Shared::AnalysisQuery.new(friendlyResourceIp, analysisFormat)
              analysisDepartment.stopInterpretationDataProduction(analysisQuery)
            end
          end
        end # Services
      end # ThinTankServices
    end # ThinkTank
  end # Demo
end # Departments