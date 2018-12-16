require 'redis'

module Workers
  module Demo
    module Analysis
      class StopInterpretationDataProducer
        include Sidekiq::Worker
        sidekiq_options retry: false

        def perform(friendlyResourceIp)
          logger.info("StopAnalysisProducer - friendlyResourceIp : #{friendlyResourceIp}")
          redisDosChannel = "#{friendlyResourceIp}_dosRawData"
          redis = Redis.new(:host => 'localhost', :port => '6379', :timeout => 0)
          redis.publish(redisDosChannel, ''.to_json)
          logger.debug("StopAnalysisProducer - redis channels affected : #{redisDosChannel}")
        end
      end # StopInterpretationDataProducer
    end # Analysis
  end # Demo
end # Workers