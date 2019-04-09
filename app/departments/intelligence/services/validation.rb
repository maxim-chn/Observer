# frozen_string_literal: true

require 'singleton'

module Departments
  module Intelligence
    ##
    # Supporting implementations for the methods in {Departments::Intelligence::Api}.
    module Services
      ##
      # Consumes {Workers::Intelligence::AddCollectionFormat}.
      class Validation
        def intelligence_query?(query)
          return if query.class == Shared::IntelligenceQuery

          throw StandardError.new("#{self.class.name} - #{__method__} - #{query} must be\
            an instance of #{Shared::IntelligenceQuery.name}.")
        end

        def ip_address?(value)
          return if value.class == Integer && value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            a positive #{Integer.name}.")
        end

        def collect_format?(value)
          return if Shared::IntelligenceFormat.formats.include?(value)

          throw StandardError.new("#{self.class.name} - #{__method__} - #{type} must be\
            of one of #{Shared::IntelligenceFormat.name} formats.")
        end
      end
    end
  end
end
