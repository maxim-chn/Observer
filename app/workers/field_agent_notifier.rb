require 'redis'

class FieldAgentNotifier
          
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(targetIp, collectStatus, collectFormat)
    puts("FieldAgentNotifier - targetIp: #{targetIp}, collectStatus: #{collectStatus}, collectFormat: #{collectFormat}")
    redis         = Redis.new(:host => 'localhost', :port => '6379')
    rawCachedData = redis.get("#{targetIp}")
    puts("rawCachedData: #{rawCachedData}")
    unless rawCachedData
      rawCachedData = "{}"
    end
    cachedData = eval(rawCachedData)
    cachedData["collectStatus"] = collectStatus
    if collectFormat
      unless cachedData["collectFormats"]
        cachedData["collectFormats"] = []
      end
      unless cachedData["collectFormats"].include?(collectFormat)
        cachedData["collectFormats"] << collectFormat
      end
    end
    redis.set(targetIp, cachedData.to_s)
    puts("Updated cachedData: #{cachedData}")
  end
  
end # FieldAgentNotifier