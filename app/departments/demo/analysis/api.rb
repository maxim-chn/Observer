require 'singleton'
require_relative './analysis_services/services'
module Departments
  module Demo
    module Analysis
      class Api
        include Singleton
        def produceInterpretationData(analysisQuery)
          Rails.logger.info("#{self.class.name} - #{__method__} - analysisQuery : #{analysisQuery.inspect()}")
          analysisServices = Departments::Demo::Analysis::AnalysisServices::Services.instance()
          analysisType = analysisQuery.analysisType
          case analysisType
          when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            analysisServices.startDosIcmpInterpretationDataProducer(analysisQuery.friendlyResourceIp)
          end
        end
        def stopInterpretationDataProduction(analysisQuery)
          Rails.logger.info("#{self.class.name} - #{__method__} - analysisQuery : #{analysisQuery.inspect()}")
          analysisServices = Departments::Demo::Analysis::AnalysisServices::Services.instance()
          analysisType = analysisQuery.analysisType
          case analysisType
          when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            analysisServices.stopDosIcmpInterpretationDataProducer(analysisQuery.friendlyResourceIp)
          end
        end
      end # AnalysisApi
    end # Analysis
  end # Demo
end # Departments