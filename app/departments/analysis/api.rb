# frozen_string_literal: true

require 'singleton'
require_relative './services/dos_icmp_report_producer.rb'

module Departments
  ##
  # Manages interpretation of intelligence data.
  # For example, it has methods that create {CyberReport}.
  module Analysis
    ##
    # Methods that are consumed by other modules / classes.
    # For example, queue a production of a particular type of {CyberReport}.
    class Api
      include Singleton

      # Queues a job for a relevant {CyberReport} producer.
      # @param [Departments::Shared::AnalysisQuery] query Query for production of {CyberReport}.
      # @param [Hash] data Intelligence data that is needed for a production of a {CyberReport}.
      # @return [Void]
      def request_cyber_report(query, data)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}, #{data}")
        case query.analysis_type
        when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
          Services::DosIcmpCyberReport.instance.queue_dos_icmp_report(
            query.friendly_resource_ip,
            data
          )
        end
      end
    end
  end
end
