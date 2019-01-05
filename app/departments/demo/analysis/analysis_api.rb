require 'singleton'

module Departments
  module Demo
    module Analysis
      class AnalysisApi
        include Singleton
        
        def produceDosInterpretationData(analysisQuery)
          Rails.logger.info("AnalysisApi - produceDosInterpretationData() - analysisQuery : #{analysisQuery.inspect()}")
          startDosIcmpInterpretationDataProducer(analysisQuery.friendlyResourceIp)
        end
        def stopDosInterpretationDataProduction(analysisQuery)
          Rails.logger.info("AnalysisApi - stopInterpretationDataProduction() - analysisQuery : #{analysisQuery.inspect()}")
          stopDosIcmpInterpretationDataProducer(analysisQuery.friendlyResourceIp)
        end
        private
        def startDosIcmpInterpretationDataProducer(friendlyResourceIp)
          Workers::Demo::Analysis::Dos::IcmpInterpretationDataProducer.perform_async(
            friendlyResourceIp,
            "#{friendlyResourceIp}#{Workers::Demo::Analysis::Dos::RedisChannels::ENDING_REDIS_CHANNEL_ICMP_DOS_INTELLIGENCE}",
            Dos::DosReport::ICMP_DOS_CYBER_REPORT
          )
          Rails.logger.debug("AnalysisApi - started Dos::IcmpInterpretationDataProducer")
        end
        def stopDosIcmpInterpretationDataProducer(friendlyResourceIp)
          Workers::Demo::Analysis::Dos::StopIcmpInterpretationDataProducer.perform_async(
            friendlyResourceIp,
            "#{friendlyResourceIp}#{Workers::Demo::Analysis::Dos::RedisChannels::ENDING_REDIS_CHANNEL_ICMP_DOS_INTELLIGENCE}",
          )
          Rails.logger.debug("AnalysisApi - started Dos::StopIcmpInterpretationDataProducer")
        end
      end # AnalysisApi
    end # Analysis
  end # Demo
end # Departments