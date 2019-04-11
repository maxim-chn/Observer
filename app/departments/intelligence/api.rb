# frozen_string_literal: true

require 'singleton'
require_relative './services/field_agent_contact.rb'
require_relative './services/validation.rb'
require_relative './services/redis_utils.rb'

module Departments
  ##
  # Manages methods that are related to intelligence.
  # For example, configuring what type of intelligence should be gathered by the field agent.
  module Intelligence
    ##
    # Methods that are consumed by other modules / classes.
    # For example, add a certain type of intelligence data to be collected.
    class Api
      include Singleton

      # Sends a {Departments::Shared::IntelligenceQuery} query
      # that specifies what type of intelligence should be gathered.
      # @param [Departments::Shared::IntelligenceQuery] query An intelligence query.
      # @return [Void]
      def start_intelligence_gathering(query)
        Services::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        Services::FieldAgentContact.instance.mission_dispatch(query)
      end

      # Sends a {Departments::Shared::IntelligenceQuery} query
      # that specifies what type of intelligence should not be gathered.
      # @param [Departments::Shared::IntelligenceQuery] query An intelligence query.
      # @return [Void]
      def stop_intelligence_gathering(query)
        Services::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        Services::FieldAgentContact.instance.mission_abort(query)
      end

      # Singnals if a collection for a certain type of intelligence is still required.
      # @param [Departments::Shared::IntelligenceQuery] query
      # @return [Boolean]
      def continue_collection?(query)
        Services::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query}.")
        begin
          redis_client = Services::RedisUtils.instance.client
          raw_cached_data = redis_client.get(query.friendly_resource_ip.to_s)
          raw_cached_data ||= '{}'
          cached_data = JSON.parse(raw_cached_data)
          collect_formats = []
          collect_formats = cached_data['collect_formats'] if cached_data.key?('collect_formats')
          return collect_formats.include?(query.collect_format)
        rescue StandardError => e
          Rails.logger.error("#{self.class.name} - #{__method__} - #{e.inspect}")
          false
        end
      end
    end
  end
end
