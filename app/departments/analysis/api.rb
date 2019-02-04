# frozen_string_literal: true

require 'singleton'
require_relative './services/dos_icmp_report_producer.rb'

module Departments
  module Analysis
    ##
    # API for consumption by other modules.
    # It allows to operate analysis services,
    # i.e. queue particular CyberReport production.
    class Api
      include Singleton

      # Will queue a job for a relevant CyberReport producer.
      # [query] Departments::Shared::AnalysisQuery.
      # [intelligence_data] Hash.
      #                     Intelligence data collected by field agent.
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
