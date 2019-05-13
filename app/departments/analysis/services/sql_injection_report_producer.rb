# frozen_string_literal: true

require 'singleton'
require_relative './validation'

module Departments
  module Analysis
    module Services
      ##
      # Consumes the {Workers::Analysis::CodeInjection::Sql::CyberReportProducer}.
      class SqlInjectionReport
        include Singleton

        # Queues a job for a production of a {CodeInjection::SqlInjectionReport}.
        # @param [Integer] ip {FriendlyResource} ip address.
        # @param [Hash] data Intelligence data.
        # @return [Void]
        def queue_a_report(ip, data)
          Services::Validation.instance.ip_address?(ip)
          Services::Validation.instance.sql_injection_intelligence_data?(data)
          Rails.logger.debug("#{self.class.name} - #{__method__} - #{ip}, #{data}.") if Rails.env.development?
          Workers::Analysis::CodeInjection::Sql::CyberReportProducer.perform_async(
            ip,
            Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT,
            data
          )
        end
      end
    end
  end
end
