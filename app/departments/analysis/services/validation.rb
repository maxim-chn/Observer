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
          return if query.class == Departments::Shared::AnalysisQuery

          throw StandardError.new("#{self.class.name} - #{__method__} - #{query} must be\
            an instance of #{Departments::Shared::AnalysisQuery.name}.")
        end

        def intelligence_data?(data)
          return if data.class == Hash

          throw StandardError.new("#{self.class.name} - #{__method__} - #{data} must be\
            an instance of #{Hash.name}.")
        end

        def intelligence_data_for_dos_icmp_report?(data)
          intelligence_data?(data)
          if data.key?('incoming_req_count')
            return if data['incoming_req_count'].class == Integer && data['incoming_req_count'] >= 0
          end

          throw StandardError.new("#{self.class.name} - #{__method__} - #{data} must be\
            an instance of #{Hash.name} with a key 'incoming_req_count' holding positive #{Integer.class} value.")
        end

        def ip_address?(ip)
          return if ip.class == Integer && ip.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - #{ip} must be\
            a positive #{Integer.name}.")
        end
      end
    end
  end
end
