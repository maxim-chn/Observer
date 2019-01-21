module Workers
  module Demo
    module Analysis
      module Dos
        class StopIcmpInterpretationDataProducer < Workers::Demo::WorkerWithRedis
          include Sidekiq::Worker
          sidekiq_options retry: false
  
          def perform(friendlyResourceIp, redisChannel)
            logger.info("#{self.class.name} - #{__method__} - friendlyResourceIp : #{friendlyResourceIp}, redis channel : #{redisChannel}")
            redisClient = nil
            begin
              redisClient = getRedisClient()
            rescue Exception => e
              logger.error("#{self.class.name} - #{__method__} - failed to get redisClient - reason - #{e.inspect()}")
              return
            end
            message = {:continueAnalysis => false}
            redisClient.publish(redisChannel, JSON.generate(message))
            logger.debug("#{self.class.name} - #{__method__} - redis channels affected : #{redisChannel}")
          end
        end # StopInterpretationDataProducer
      end # Dos
    end # Analysis
  end # Demo
end # Workers