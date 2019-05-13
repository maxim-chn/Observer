# frozen_string_literal: true

require 'singleton'
require_relative './services/dos_icmp_report_producer.rb'
require_relative './services/sql_injection_report_producer.rb'
require_relative './services/validation.rb'

module Departments
  ##
  # Manages the interpretation of the intelligence data.
  # For example, it has methods that create {CyberReport}.
  module Analysis
    ##
    # Methods that are consumed by other modules. For example, {Departments::ThinkTank}.
    class Api
      include Singleton

      # Queues a job for a relevant {CyberReport} producer.
      # @param [Departments::Shared::AnalysisQuery] query Query for production of a {CyberReport}.
      # @param [Hash] data Intelligence data that is needed for a production of a {CyberReport}.
      # @return [Void]
      def request_cyber_report(query, data)
        Services::Validation.instance.analysis_query?(query)
        Services::Validation.instance.intelligence_data?(data)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}, #{data}.") if Rails.env.development?
        case query.analysis_type
        when Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
          Services::DosIcmpCyberReport.instance.queue_a_report(
            query.friendly_resource_ip,
            data
          )
        when Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
          Services::SqlInjectionReport.instance.queue_a_report(
            query.friendly_resource_ip,
            data
          )
        end
      end
    end
  end
end
