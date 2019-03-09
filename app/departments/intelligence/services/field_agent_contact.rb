# frozen_string_literal: true

require 'singleton'

module Departments
  module Intelligence
    ##
    # Any long / supporting implementations that are used in {Departments::Intelligence::Api}
    # are under this module.
    module Services
      ##
      # This class allows to persist {Departments::Shared::IntelligenceQuery},
      # for the field agent to know what to collect.
      class FieldAgentContact
        include Singleton

        # Initiates background process to persist Departments::Shared::IntelligenceQuery
        # in {Redis}[https://redis.io/documentation].
        # Its to be used to pass to field agent what to collect.
        # [Departments::Shared::IntelligenceQuery] query.
        # @return [Void]
        def mission_dispatch(query)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
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
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
          Workers::Intelligence::RemoveCollectionFormat.perform_async(
            query.friendly_resource_ip,
            query.collect_format
          )
        end
      end
    end
  end
end
