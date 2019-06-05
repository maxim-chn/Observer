# frozen_string_literal: true

require 'singleton'
require_relative './services/field_agent_contact.rb'
require_relative './services/validation.rb'
require_relative './services/redis_utils.rb'

module Departments
  ##
  # Manages the methods that are related to the intelligence.
  # For example, configuring what type of the intelligence should be gathered by the field agent.
  module Intelligence
    ##
    # Methods that are consumed by the other modules / classes. For example, {Departments::ThinkTank}.
    class Api
      include Singleton

      # Dispatches a {Departments::Shared::IntelligenceQuery} to the
      # {Departments::Intelligence::Services::FieldAgentContact}.
      # The query contains the type of intelligence to be gathered.
      # @param [Departments::Shared::IntelligenceQuery] query An intelligence query.
      # @return [Void]
      def start_intelligence_gathering(query)
        Services::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}.") if Rails.env.development?
        Services::FieldAgentContact.instance.mission_dispatch(query)
      end

      # Dispatches a {Departments::Shared::IntelligenceQuery} to the
      # {Departments::Intelligence::Services::FieldAgentContact}.
      # The query contains the type of intelligence to not be gathered.
      # @param [Departments::Shared::IntelligenceQuery] query An intelligence query.
      # @return [Void]
      def stop_intelligence_gathering(query)
        Services::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}.") if Rails.env.development?
        Services::FieldAgentContact.instance.mission_abort(query)
      end

      # Is the collection of a ceratain type of intelligence is still required?
      # @param [Departments::Shared::IntelligenceQuery] query An intelligence query.
      # @return [Boolean]
      def continue_collection?(query)
        Services::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}.") if Rails.env.development?
        begin
          redis_client = Services::RedisUtils.instance.client
          raw_cached_data = redis_client.get(query.friendly_resource_ip.to_s)
          raw_cached_data ||= '{}'
          cached_data = JSON.parse(raw_cached_data)
          collect_formats = []
          collect_formats = cached_data['collect_formats'] if cached_data.key?('collect_formats')
          if Rails.env.development?
            message = "#{self.class.name} - #{__method__} - intelligence formats to collect: #{collect_formats}."
            Rails.logger.info(message)
          end
          redis_client.quit unless redis_client.nil?
          return collect_formats.include?(query.collect_format)
        rescue StandardError => e
          redis_client.quit unless redis_client.nil?
          Rails.logger.error("#{self.class.name} - #{__method__} - #{e.inspect}")
          false
        end
      end
    end
  end
end
