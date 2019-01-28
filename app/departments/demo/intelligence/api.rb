# frozen_string_literal: true

require 'singleton'
require_relative './services/field_agent_contact.rb'

module Departments
  module Demo
    module Intelligence
      ##
      # This is an [API] for consumption by other modules in Observer.
      class Api
        include Singleton

        # +query+ - an object of type [IntelligenceQuery].
        def start_intelligence_gathering(query)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
          field_agent_contact = Services::FieldAgentContact::Api.instance
          field_agent_contact.mission_dispatch(query)
        end

        # +query+ - an object of type [IntelligenceQuery].
        def stop_intelligence_gathering(query)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
          field_agent_contact = Services::FieldAgentContact::Api.instance
          field_agent_contact.mission_abort(query)
        end
      end
    end
  end
end
