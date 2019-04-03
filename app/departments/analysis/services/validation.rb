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

        def ip_address?(ip)
          return if ip.class == Integer

          throw StandardError.new("#{self.class.name} - #{__method__} - #{ip} must be\
            an instance of #{Integer.name}.")
        end
      end
    end
  end
end
