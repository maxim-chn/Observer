require 'singleton'

module Departments
  module Demo
    module Analysis
      class AnalysisApi  
        include Singleton
        
        def produceInterpretationData(analysisQuery)
          Rails.logger.info("AnalysisApi - produceInterpretationData() - analysisQuery : #{analysisQuery.inspect()})")
          Workers::Demo::Analysis::InterpretationDataProducer.perform_async(
            analysisQuery.friendlyResourceId, analysisQuery.friendlyResourceIp
          )
        end
        def stopInterpretationDataProduction(analysisQuery)
          Rails.logger.info("AnalysisApi - stopInterpretationDataProduction() - analysisQuery : #{analysisQuery.inspect()})")
          Workers::Demo::Analysis::StopInterpretationDataProducer.perform_async(analysisQuery.friendlyResourceIp)
        end
  
      end # AnalysisApi
    end # Analysis
  end # Demo
end # Departments