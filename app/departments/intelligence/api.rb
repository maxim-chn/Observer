# frozen_string_literal: true

require 'singleton'
require_relative './services/field_agent_contact.rb'

module Departments
  module Intelligence
    ##
    # API for consumption by other modules.
    class Api
      include Singleton

      # [query] Departments::Shared::IntelligenceQuery.
      def start_intelligence_gathering(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        field_agent_contact = Services::FieldAgentContact.instance
        field_agent_contact.mission_dispatch(query)
      end

      # [query] Departments::Shared::IntelligenceQuery.
      def stop_intelligence_gathering(query)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
        field_agent_contact = Services::FieldAgentContact.instance
        field_agent_contact.mission_abort(query)
      end
    end
  end
end
