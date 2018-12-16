require 'redis'

module Workers
  module Demo
    module Intelligence
      class RemoveCollectionFormat        
        include Sidekiq::Worker
        sidekiq_options retry: false, queue: 'field_agent_notifier'

        def perform(friendlyResourceIp, collectFormat)
          logger.info("RemoveCollectionFormat - friendlyResourceIp : #{friendlyResourceIp}, collectFormat : #{collectFormat}")
          redis         = Redis.new(:host => 'localhost', :port => '6379')
          rawCachedData = redis.get("#{friendlyResourceIp}")
          rawCachedData = '{}' unless rawCachedData
          logger.debug("rawCachedData: #{rawCachedData}")
          cachedData        = eval(rawCachedData)
          cachedDataChanged = false
          cachedData['collectFormats'] = [] unless cachedData.key?('collectFormats')
          if cachedData['collectFormats'].include?(collectFormat)
            cachedData['collectFormats'].delete(collectFormat)
            cachedDataChanged = true
          end
          if cachedDataChanged
            logger.debug("Will write to redis updated cachedData: #{cachedData}")
            redis.set(friendlyResourceIp, cachedData.to_s)
          end
        end
      end # RemoveCollectionFormat
    end # Intelligence
  end # Demo
end # Workers