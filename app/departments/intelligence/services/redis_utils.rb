# frozen_string_literal: true

require 'singleton'
require 'redis'

module Departments
  module Intelligence
    module Services
      ##
      # Services, like redis client, for {Departments::Intelligence}.
      class RedisUtils
        include Singleton

        def client
          client = nil
          begin
            client = Redis.new(host: 'localhost', port: '6379', timeout: 0) if Rails.env.development?
            client = Redis.new(timeout: 0) if Rails.env.production?
            return client if client
          rescue StandardError => e
            throw StandardError.new("#{self.class.name} - #{__method__} - #{e.inspect}")
          end
          throw StandardError.new("#{self.class.name} - #{__method__} - reason unknown.")
        end
      end
    end
  end
end
