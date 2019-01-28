# frozen_string_literal: true

module Workers
  module Demo
    module Intelligence
      ##
      # A Sidekiq that persists in Redis intelligence data formats to not be collected.
      # These formats affect [FieldAgent].
      class RemoveCollectionFormat < Workers::Demo::WorkerWithRedis
        include Sidekiq::Worker
        sidekiq_options retry: false, queue: 'field_agent_notifier'

        # Creates a process that updates in Redis intelligence data,
        # to not be collected by [FieldAgent].
        # +ip+ - friendly resource ip.
        # +collect_format+ - intelligence data collection format.
        def perform(ip, collect_format)
          logger.info("#{self.class.name} - #{__method__} - IP : #{friendlyResourceIp}, collect_format : #{collect_format}")
          begin
            client = redis_client
            raw_cached_data = client.get(ip.to_s)
            logger.debug("#{self.class.name} - #{__method__} - raw_cached_data: #{raw_cached_data}")
            raw_cached_data ||= '{}'
            cached_data = JSON.parse(raw_cached_data)
            dirty_flag = false # Has cached data been changed.
            cached_data[:collect_formats] = [] unless cached_data.key?(:collect_formats)
            if cached_data[:collect_formats].include?(collect_format)
              cachedData[:collect_formats].delete(collect_format)
              dirty_flag = true
            end
            return unless dirty_flag

            client.set(ip, JSON.generate(cached_data))
            logger.debug("#{self.class.name} - #{__method__} - newly cached data : #{cached_data}")
          rescue StandardError => e
            logger.error("#{self.class.name} - #{__method__} - failed - reason - #{e.inspect}")
          end
        end
      end
    end
  end
end
