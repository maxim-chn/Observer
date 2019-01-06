require 'redis'
module Workers
  module Demo
    module Intelligence
      class RemoveCollectionFormat        
        include Sidekiq::Worker
        sidekiq_options retry: false, queue: 'field_agent_notifier'
        def perform(friendlyResourceIp, collectFormat)
          logger.info("#{self.class.name} - #{__method__} - friendlyResourceIp : #{friendlyResourceIp}, collectFormat : #{collectFormat}")
          redis         = Redis.new(:host => 'localhost', :port => '6379')
          rawCachedData = redis.get("#{friendlyResourceIp}")
          logger.debug("#{self.class.name} - #{__method__} - rawCachedData: #{rawCachedData}")
          rawCachedData               = '{}' unless rawCachedData
          cachedData                  = eval(rawCachedData)
          cachedDataChanged           = false
          cachedData[:collectFormats] = [] unless cachedData.key?(:collectFormats)
          if cachedData[:collectFormats].include?(collectFormat)
            cachedData[:collectFormats].delete(collectFormat)
            cachedDataChanged = true
          end
          if cachedDataChanged
            redis.set(friendlyResourceIp, cachedData.to_s)
            logger.debug("#{self.class.name} - #{__method__} - has written updated redis with cachedData: #{cachedData}")
          end
        end
      end # RemoveCollectionFormat
    end # Intelligence
  end # Demo
end # Workers