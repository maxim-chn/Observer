require 'redis'

module Workers
  module Demo
    module Analysis
      module Dos
        class StopIcmpInterpretationDataProducer
          include Sidekiq::Worker
          sidekiq_options retry: false
  
          def perform(friendlyResourceIp, redisChannel)
            logger.info("StopIcmpInterpretationDataProducer - friendlyResourceIp : #{friendlyResourceIp}, redis channel : #{redisChannel}")
            redis = Redis.new(:host => 'localhost', :port => '6379', :timeout => 0)
            redis.publish(redisChannel, ''.to_json)
            logger.debug("StopIcmpInterpretationDataProducer - redis channels affected : #{redisChannel}")
          end
        end # StopInterpretationDataProducer
      end # Dos
    end # Analysis
  end # Demo
end # Workers