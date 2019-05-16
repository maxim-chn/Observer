# frozen_string_literal: true

module Workers
  ##
  # Scopes the workers that affect the collection of the intelligence data.
  module Intelligence
    ##
    # Persists the desired intelligence data formats in the {https://redis.io/ Redis}.
    # These formats affect the field agent, located at the {FriendlyResource}.
    class AddCollectionFormat < Workers::WorkerWithRedis
      include Sidekiq::Worker
      sidekiq_options retry: false, queue: 'field_agent_notifier'

      # Creates a process that updates the desirable intelligence data.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Departments::Shared::IntelligenceFormat] collect_format
      # @return [Void]
      def perform(ip, collect_format, log: false)
        logger.info("#{self.class.name} - #{__method__} - #{ip}, #{collect_format}") if log
        begin
          client = redis_client
          raw_cached_data = client.get(ip.to_s)
          logger.info("#{self.class.name} - #{__method__} - raw_cached_data : #{raw_cached_data}.") if log
          raw_cached_data ||= '{}'
          cached_data = JSON.parse(raw_cached_data)
          dirty_flag = false # Has cached data been changed.
          cached_data['collect_formats'] = [] unless cached_data.key?('collect_formats')
          unless cached_data['collect_formats'].include?(collect_format)
            cached_data['collect_formats'] << collect_format
            dirty_flag = true
          end
          return unless dirty_flag

          client.set(ip, JSON.generate(cached_data))
          logger.info("#{self.class.name} - #{__method__} - new cached data : #{cached_data}.") if log
        rescue StandardError => e
          logger.error("#{self.class.name} - #{__method__} - failed - #{e.inspect}.")
        end
      end
    end
  end
end
