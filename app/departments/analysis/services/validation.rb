# frozen_string_literal: true

require 'singleton'

module Departments
  module Analysis
    module Services
      ##
      # Contains validation methods for {Departments::Analysis} module.
      class Validation
        include Singleton

        def analysis_query?(query)
          return if query.class == Shared::AnalysisQuery

          error_message = "#{self.class.name} - #{__method__} - #{query}"
          error_message += " must be an instance of #{Shared::AnalysisQuery.name}."
          throw StandardError.new(error_message)
        end

        def intelligence_data?(data)
          return if data.class == Hash

          error_message = "#{self.class.name} - #{__method__} - #{data} must be an instance of #{Hash.name}."
          throw StandardError.new(error_message)
        end

        def dos_icmp_intelligence_data?(data)
          intelligence_data?(data)
          if data.key?('incoming_req_count')
            return if data['incoming_req_count'].class == Integer && data['incoming_req_count'] >= 0
          end

          error_message = "#{self.class.name} - #{__method__} - #{data} must be an instance of #{Hash.name} with"
          error_message += " a key 'incoming_req_count' holding positive #{Integer.class} value."
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

        def ip_address?(ip)
          return if ip.class == Integer && ip.positive?

          error_message = "#{self.class.name} - #{__method__} - #{ip} must be a positive #{Integer.name}."
          throw StandardError.new(error_message)
        end
      end
    end
  end
end
