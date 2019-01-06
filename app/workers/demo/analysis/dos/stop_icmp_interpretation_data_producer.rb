require 'redis'

module Workers
  module Demo
    module Analysis
      module Dos
        class StopIcmpInterpretationDataProducer
          include Sidekiq::Worker
          sidekiq_options retry: false
  
          def perform(friendlyResourceIp, redisChannel)
            logger.info("#{self.class.name} - #{__method__} - friendlyResourceIp : #{friendlyResourceIp}, redis channel : #{redisChannel}")
            redis = Redis.new(:host => 'localhost', :port => '6379', :timeout => 0)
            message = {:continueAnalysis => false}
            redis.publish(redisChannel, JSON.generate(message))
            logger.debug("#{self.class.name} - #{__method__} - redis channels affected : #{redisChannel}")
          end
        end # StopInterpretationDataProducer
      end # Dos
    end # Analysis
  end # Demo
end # Workers