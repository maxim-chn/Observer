require 'redis'
module Workers
  module Demo
    class WorkerWithRedis
      private
      def getRedisClient()
        redisClient = nil
        begin
          if Rails.env.development?
            redisClient = Redis.new(:host => 'localhost', :port => '6379', :timeout => 0)
          end
          if Rails.env.production?
            redisClient = Redis.new(:timeout => 0)
          end
        rescue Exception => e
          throw Exception.new("#{self.class.name} - #{__method__} - has failed to initialize redis client - reason - #{e.inspect()}")
        end
        if (redisClinet)
          return redisClient
        else
          throw Exception.new("#{self.class.name} - #{__method__} - has failed to initialize redis client.")
        end
      end
    end # WorkerWithRedis
  end # Demo
end # Workers