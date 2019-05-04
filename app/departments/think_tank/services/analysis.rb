# frozen_string_literal: true

require 'singleton'

module Departments
  module ThinkTank
    ##
    # Supporting the implementations for the methods that are used in the {Departments::ThinkTank::Api}.
    module Services
      ##
      # Consumes the {Departments::Analysis::Api}.
      class Analysis
        include Singleton

        # @param [Departments::Shared::AnalysisQuery] query An analysis query.
        # @param [Hash] data Intelligence data.
        # @return [Void]
        def analyze(query, data)
          if Rails.env.development?
            debug_message = "#{self.class.name} - #{__method__} - #{query.inspect}, #{data}."
            Rails.logger.info(debug_message)
          end
          Departments::Analysis::Api.instance.request_cyber_report(query, data)
        end
      end
    end
  end
end
