# frozen_string_literal: true

require 'redis'

module Workers
  module Demo
    ##
    # Sidekiq manages our background processing and it needs
    # Redis. Hence, every worker must have Redis connection.
    class WorkerWithRedis
      private

      def redis_client
        client = nil
        begin
          client = Redis.new(host: 'localhost', port: '6379', timeout: 0) if Rails.env.development?
          client = Redis.new(timeout: 0) if Rails.env.production?
        rescue StandardError => e
          throw StandardError.new("#{self.class.name} - #{__method__} - failed - reason - #{e.inspect}")
        end
        redisClient if client
        throw StandardError.new("#{self.class.name} - #{__method__} - has failed - reason - unknown.")
      end
    end
  end
end
