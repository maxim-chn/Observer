# frozen_string_literal: true

require 'singleton'
require_relative './validation.rb'

module Departments
  module Intelligence
    ##
    # Supporting implementations for the methods in {Departments::Intelligence::Api}.
    module Services
      ##
      # Consumes {Workers::Intelligence::AddCollectionFormat}.
      class FieldAgentContact
        include Singleton

        # Initiates background process to persist Departments::Shared::IntelligenceQuery
        # in {Redis}[https://redis.io/documentation].
        # Its to be used to pass to field agent what to collect.
        # [Departments::Shared::IntelligenceQuery] query An intelligence query.
        # @return [Void]
        def mission_dispatch(query)
          Services::Validation.instance.ip_address?(query.friendly_resource_ip)
          Services::Validation.instance.collect_format?(query.collect_format)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}.")
          Workers::Intelligence::AddCollectionFormat.perform_async(
            query.friendly_resource_ip,
            query.collect_format
          )
        end

        # Initiates background process to persist Departments::Shared::IntelligenceQuery
        # in {Redis}[https://redis.io/documentation].
        # Its to be used to pass to field agent what to not collect.
        # [Departments::Shared::IntelligenceQuery] query.
        # @return [Void]
        def mission_abort(query)
          Services::Validation.instance.ip_address?(query.friendly_resource_ip)
          Services::Validation.instance.collect_format?(query.collect_format)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}.")
          Workers::Intelligence::RemoveCollectionFormat.perform_async(
            query.friendly_resource_ip,
            query.collect_format
          )
        end
      end
    end
  end
end
