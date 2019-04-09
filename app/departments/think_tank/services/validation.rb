# frozen_string_literal: true

require 'singleton'

module Departments
  module ThinkTank
    module Services
      ##
      # Consumes {Departments::Analysis::Api}.
      class Validation
        include Singleton

        def integer?(value)
          return if value.class == Integer

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Integer.name}.")
        end

        def id?(value)
          integer?(value)
          return if value >= 0

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            a non-negative #{Integer.name}.")
        end

        def ip_address?(value)
          return if value.class == Integer && value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            a positive #{Integer.name}.")
        end

        def intelligence_data?(value)
          return if value.class == Hash

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Hash.name}.")
        end

        def dos_icmp_intelligence_data?(data)
          intelligence_data?(data)
          if data.key?('incoming_req_count')
            return if data['incoming_req_count'].class == Integer && data['incoming_req_count'] >= 0
          end

          throw StandardError.new("#{self.class.name} - #{__method__} - #{data} must be\
            an instance of #{Hash.name} with a key 'incoming_req_count' holding positive #{Integer.class} value.")
        end

        def cyper_report_type?(type)
          return if Shared::AnalysisType.formats.include?(type)

          throw StandardError.new("#{self.class.name} - #{__method__} - #{type} must be\
            of one of #{Shared::AnalysisType.name} formats.")
        end

        def page?(value)
          integer?(value)
          return if value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Integer.name} greater than 0.")
        end

        def page_size?(value)
          integer?(value)
          return if value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            an instance of #{Integer.name} greater than 0.")
        end
      end
    end
  end
end
