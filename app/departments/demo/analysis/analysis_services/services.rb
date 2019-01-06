require 'singleton'
module Departments
  module Demo
    module Analysis
      module AnalysisServices
        class Services
          include Singleton
          def startDosIcmpInterpretationDataProducer(friendlyResourceIp)
            Rails.logger.debug("#{self.class.name} - #{__method__} - friendlyResourceIp : #{friendlyResourceIp}")
            Workers::Demo::Analysis::Dos::IcmpInterpretationDataProducer.perform_async(
              friendlyResourceIp,
              "#{friendlyResourceIp}#{Workers::Demo::Analysis::Dos::RedisChannels::ENDING_REDIS_CHANNEL_ICMP_DOS_INTELLIGENCE}",
              Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            )
            Rails.logger.debug("#{self.class.name} - #{__method__} - started Dos::IcmpInterpretationDataProducer")
          end
          def stopDosIcmpInterpretationDataProducer(friendlyResourceIp)
            Rails.logger.debug("#{self.class.name} - #{__method__} - friendlyResourceIp : #{friendlyResourceIp}")
            Workers::Demo::Analysis::Dos::StopIcmpInterpretationDataProducer.perform_async(
              friendlyResourceIp,
              "#{friendlyResourceIp}#{Workers::Demo::Analysis::Dos::RedisChannels::ENDING_REDIS_CHANNEL_ICMP_DOS_INTELLIGENCE}",
            )
            Rails.logger.debug("#{self.class.name} - #{__method__} - started Dos::StopIcmpInterpretationDataProducer")
          end
        end # Services
      end # AnalysisServices
    end # Analysis
  end # Demo
end # Departments