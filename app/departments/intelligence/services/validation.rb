# frozen_string_literal: true

require 'singleton'

module Departments
  module Intelligence
    module Services
      ##
      # Validations for the inputs / outputs of the methods in {Departments::Intelligence} module.
      class Validation
        include Singleton

        def intelligence_query?(query)
          if query.class == Shared::IntelligenceQuery
            ip_address?(query.friendly_resource_ip)
            collect_format?(query.collect_format)
            return
          end
          error_message = "#{self.class.name} - #{__method__} - #{query}"
          error_message += " must be an instance of #{Shared::IntelligenceQuery.name}."
          throw StandardError.new(error_message)
        end

        def ip_address?(value)
          return if value.class == Integer && value.positive?

          error_message = "#{self.class.name} - #{__method__} - #{value} must be a positive #{Integer.name}."
          throw StandardError.new(error_message)
        end

        def collect_format?(value)
          return if Shared::IntelligenceFormat.formats.include?(value)

          error_message = "#{self.class.name} - #{__method__} - #{value}"
          error_message += "must be one of #{Shared::IntelligenceFormat.name} formats."
          throw StandardError.new(error_message)
        end
      end
    end
  end
end
