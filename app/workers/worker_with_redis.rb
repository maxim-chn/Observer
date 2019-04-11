# frozen_string_literal: true

require 'redis'

##
# Holds all Worker classes. They represent the {background processes}[https://en.wikipedia.org/wiki/Background_process].
module Workers
  ##
  # {Sidekiq}[https://sidekiq.org/] manages our background processing and it needs
  # {Redis}[https://redis.io/]. Hence, every worker must have a Redis connection.
  class WorkerWithRedis
    private

    # A {redis client}[https://github.com/redis/redis-rb] with an active connection.
    # @return [Redis]
    def redis_client
      client = nil
      begin
        client = Redis.new(host: 'localhost', port: '6379', timeout: 0) if Rails.env.development?
        client = Redis.new(timeout: 0) if Rails.env.production?
        return client if client
      rescue StandardError => e
        throw StandardError.new("#{self.class.name} - #{__method__} - failed - reason - #{e.inspect}")
      end
      throw StandardError.new("#{self.class.name} - #{__method__} - failed - reason - unknown.")
    end
  end
end
