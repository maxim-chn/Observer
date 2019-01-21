module Workers
  module Demo
    module Intelligence
      class AddCollectionFormat < Workers::Demo::WorkerWithRedis
        include Sidekiq::Worker
        sidekiq_options retry: false, queue: 'field_agent_notifier'
        def perform(friendlyResourceIp, collectFormat)
          logger.info("#{self.class.name} - #{__method__} - friendlyResourceIp : #{friendlyResourceIp}, collectFormat : #{collectFormat}")
          redisClient = nil
          begin
            redisClient = getRedisClient()
          rescue Exception => e
            logger.error("#{self.class.name} - #{__method__} - failed to get redisClient - reason - #{e.inspect()}")
            return
          end
          rawCachedData = redisClient.get("#{friendlyResourceIp}")
          logger.debug("#{self.class.name} - #{__method__} - rawCachedData: #{rawCachedData}")
          rawCachedData               = '{}' unless rawCachedData
          cachedData                  = eval(rawCachedData)
          cachedDataChanged           = false
          cachedData[:collectFormats] = [] unless cachedData.key?(:collectFormats)
          unless cachedData[:collectFormats].include?(collectFormat)
            cachedData[:collectFormats] << collectFormat
            cachedDataChanged = true
          end
          if cachedDataChanged
            redisClient.set(friendlyResourceIp, cachedData.to_s)
            logger.debug("#{self.class.name} - #{__method__} - has updated redis with cachedData : #{cachedData}")
          end
        end
      end # AddCollectionFormat
    end # Intelligence
  end # Demo
end # Workers