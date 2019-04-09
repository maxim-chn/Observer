# frozen_string_literal: true

require 'singleton'
require_relative './services/field_agent_contact.rb'
require_relative './services/validation.rb'

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
        Service::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        Services::FieldAgentContact.instance.mission_dispatch(query)
      end

      # Sends a {Departments::Shared::IntelligenceQuery} query
      # that specifies what type of intelligence should not be gathered.
      # @param [Departments::Shared::IntelligenceQuery] query An intelligence query.
      # @return [Void]
      def stop_intelligence_gathering(query)
        Service::Validation.instance.intelligence_query?(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        Services::FieldAgentContact.instance.mission_abort(query)
      end
    end
  end
end
