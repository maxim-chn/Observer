# frozen_string_literal: true

require 'singleton'

module Departments
  module ThinkTank
    ##
    # Any long / supporting implementations that are used in {Departments::ThinkTank::Api}
    # are under this module.
    module Services
      ##
      # Consumes {Departments::Analysis::Api}.
      class Analysis
        include Singleton

        # @param [Departments::Shared::AnalysisQuery] query An analysis query.
        # @param [Hash] data Intelligence data.
        # @return [Void]
        def analyze(query, data)
          Rails.logger.info("#{self.class.name} - #{__method__} - Query : #{query.inspect},\
             Intelligence Data: #{data}")
          Departments::Analysis::Api.instance.request_cyber_report(query, data)
        end
      end
    end
  end
end
