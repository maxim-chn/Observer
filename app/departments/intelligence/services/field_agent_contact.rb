# frozen_string_literal: true

require 'singleton'
require_relative './validation.rb'

module Departments
  module Intelligence
    ##
    # Supporting methods for the {Departments::Intelligence::Api}.
    module Services
      ##
      # Consumes {Workers::Intelligence::AddCollectionFormat}, {Workers::Intelligence::RemoveCollectionFormat}.
      class FieldAgentContact
        include Singleton

        # Initiates a background process to persist {Departments::Shared::IntelligenceQuery}
        # in {https://redis.io/documentation Redis}.
        # @param [Departments::Shared::IntelligenceQuery] query An intelligence query.
        # @return [Void]
        def mission_dispatch(query)
          Services::Validation.instance.ip_address?(query.friendly_resource_ip)
          Services::Validation.instance.collect_format?(query.collect_format)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}.") if Rails.env.development?
          Workers::Intelligence::AddCollectionFormat.perform_async(
            query.friendly_resource_ip,
            query.collect_format,
            Rails.env.development?
          )
        end

        # Initiates a background process to persist {Departments::Shared::IntelligenceQuery}
        # in {https://redis.io/documentation Redis}.
        # @param [Departments::Shared::IntelligenceQuery] query
        # @return [Void]
        def mission_abort(query)
          Services::Validation.instance.ip_address?(query.friendly_resource_ip)
          Services::Validation.instance.collect_format?(query.collect_format)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}.") if Rails.env.development?
          Workers::Intelligence::RemoveCollectionFormat.perform_async(
            query.friendly_resource_ip,
            query.collect_format,
            Rails.env.development?
          )
        end
      end
    end
  end
end
