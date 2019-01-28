# frozen_string_literal: true

require 'singleton'

module Departments
  module Demo
    module Intelligence
      module Services
        ##
        # This class allows to persist [IntelligenceQuery],
        # for [FieldAgent] to know what to collect.
        class FieldAgentContact
          include Singleton

          # Initiates background process to persist [IntelligenceQuery] in [Redis].
          # +query+ - an object of type [IntelligenceQuery].
          # Its to be used to pass to [FieldAgent] what to collect.
          def mission_dispatch(query)
            Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
            Workers::Demo::Intelligence::AddCollectionFormat.perform_async(
              query.friendly_resource_ip,
              query.collect_format
            )
          end

          # Initiates background process to persist [IntelligenceQuery] in [Redis].
          # +query+ - an object of type [IntelligenceQuery].
          # Its to be used to pass to [FieldAgent] what to not collect.
          def mission_abort(query)
            Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
            Workers::Demo::Intelligence::RemoveCollectionFormat.perform_async(
              query.friendly_resource_ip,
              quer.collect_format
            )
          end
        end
      end
    end
  end
end
