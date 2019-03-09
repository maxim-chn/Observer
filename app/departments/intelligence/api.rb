# frozen_string_literal: true

require 'singleton'
require_relative './services/field_agent_contact.rb'

module Departments
  ##
  # Manages any methods related to intelligence.
  # For example, the methods configure what type of intelligence should be gathered by
  # field agent.
  module Intelligence
    ##
    # Methods that are consumed by other modules / classes.
    # For example, add a certain type of intelligence data to be collected.
    class Api
      include Singleton

      # @param [Departments::Shared::IntelligenceQuery] query Intelligence query.
      # @return [Void]
      def start_intelligence_gathering(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        field_agent_contact = Services::FieldAgentContact.instance
        field_agent_contact.mission_dispatch(query)
      end

      # @param [Departments::Shared::IntelligenceQuery] query Intelligence query.
      # @return [Void]
      def stop_intelligence_gathering(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        field_agent_contact = Services::FieldAgentContact.instance
        field_agent_contact.mission_abort(query)
      end
    end
  end
end
