# frozen_string_literal: true

require 'singleton'

module Departments
  module ThinkTank
    module Services
      ##
      # Validations for the inputs / outputs of the methods in {Departments::ThinkTank} module.
      class Validation
        include Singleton

        def integer?(value)
          return if value.class == Integer

          error_message = "#{self.class.name} - #{__method__} - #{value} must be an instance of #{Integer.name}."
          throw StandardError.new(error_message)
        end

        def id?(value)
          integer?(value)
          return if value >= 0

          error_message = "#{self.class.name} - #{__method__} - #{value} must be a non-negative #{Integer.name}."
          throw StandardError.new(error_message)
        end

        def ip_address?(value)
          integer?(value)
          return if value.positive?

          error_message = "#{self.class.name} - #{__method__} - #{value} must be a positive #{Integer.name}."
          throw StandardError.new(error_message)
        end

        def intelligence_data?(value)
          return if value.class == Hash

          error_message = "#{self.class.name} - #{__method__} - #{value} must be an instance of #{Hash.name}."
          throw StandardError.new(error_message)
        end

        def dos_icmp_intelligence_data?(data)
          intelligence_data?(data)
          if data.key?('incoming_req_count')
            return if data['incoming_req_count'].class == Integer && data['incoming_req_count'] >= 0
          end
          error_message = "#{self.class.name} - #{__method__} - #{data} must be an instance of #{Hash.name}"
          error_message += " with a key 'incoming_req_count' holding positive #{Integer.class} value."
          throw StandardError.new(error_message)
        end

        def sql_injection_intelligence_data?(data)
          intelligence_data?(data)
          if data.key?('uris')
            return if data['uris'].class == Array && !data['uris'].empty?
          end
          error_message = "#{self.class.name} - #{__method__} - #{data} must be an instance of #{Hash.name}"
          error_message += " with the key 'uris' holding an #{Array.name} value."
          throw StandardError.new(error_message)
        end

        def cyper_report_type?(type)
          return if Shared::AnalysisType.formats.include?(type)

          error_message = "#{self.class.name} - #{__method__} - #{type} must be"
          error_message += " one of #{Shared::AnalysisType.name} formats."
          throw StandardError.new(error_message)
        end

        # The first page is at 1.
        def page?(value)
          integer?(value)
          return if value.positive?

          error_message = "#{self.class.name} - #{__method__} - #{value} must be a positive #{Integer.name}."
          throw StandardError.new(error_message)
        end

        def page_size?(value)
          integer?(value)
          return if value.positive?

          error_message = "#{self.class.name} - #{__method__} - #{value} must be a positive #{Integer.name}."
          throw StandardError.new(error_message)
        end
      end
    end
  end
end
