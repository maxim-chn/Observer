# frozen_string_literal: true

module Workers
  module Intelligence
    ##
    # Removes the intelligence format that is no longer necessary from the {https://redis.io/ Redis}.
    # These formats affect the field agent, located at the {FriendlyResource}.
    class RemoveCollectionFormat < Workers::WorkerWithRedis
      include Sidekiq::Worker
      sidekiq_options retry: false, queue: 'field_agent_notifier'

      # Creates a process that updates the none-desirable intelligence data.
      # @param [Integer] ip FriendlyResource ip address.
      # @param [Departments::Shared::IntelligenceFormat] collect_format
      # @return [Void]
      def perform(ip, collect_format, log = false)
        logger.info("#{self.class.name} - #{__method__} - #{ip}, #{collect_format}") if log
        begin
          client = redis_client
          raw_cached_data = client.get(ip.to_s)
          logger.debug("#{self.class.name} - #{__method__} - raw_cached_data : #{raw_cached_data}.") if log
          raw_cached_data ||= '{}'
          cached_data = JSON.parse(raw_cached_data)
          dirty_flag = false # Has cached data been changed.
          cached_data['collect_formats'] = [] unless cached_data.key?('collect_formats')
          if cached_data['collect_formats'].include?(collect_format)
            cached_data['collect_formats'].delete(collect_format)
            dirty_flag = true
          end
          return unless dirty_flag

          client.set(ip, JSON.generate(cached_data))
          logger.debug("#{self.class.name} - #{__method__} - new cached data : #{cached_data}.") if log
        rescue StandardError => e
          logger.error("#{self.class.name} - #{__method__} - failed - #{e.inspect}.")
        ensure
          client.quit unless client.nil?
        end
      end
    end
  end
end
