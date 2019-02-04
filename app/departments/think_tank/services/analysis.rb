# frozen_string_literal: true

require 'singleton'

module Departments
  module ThinkTank
    module Services
      ##
      # Consumes Departments::Analysis::Api.
      class Analysis
        include Singleton

        def analyze(query, data)
          Rails.logger.info("#{self.class.name} - #{__method__} - Query : #{query.inspect},\
             Intelligence Data: #{data}")
          Departments::Analysis::Api.instance.request_cyber_report(query, data)
        end
      end
    end
  end
end
