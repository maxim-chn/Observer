# frozen_string_literal: true

require 'singleton'

module Departments
  module Analysis
    module Services
      ##
      # Has access to Workers::Analysis::Dos::Icmp::CyberReportProducer.
      class DosIcmpCyberReport
        include Singleton

        # Will queue a job for production of Dos::IcmpCyberReport.
        # [ip] Integer.
        #      FriendlyResource ip address.
        # [data] Hash.
        #        Intelligence data collected by field agent.
        def queue_dos_icmp_report(ip, data)
          Rails.logger.debug(
            "#{self.class.name} - #{__method__} - #{ip}\n \
            #{data}"
          )
          Workers::Analysis::Dos::Icmp::CyberReportProducer.perform_async(
            ip,
            Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
            data
          )
          Rails.logger.debug("#{self.class.name} - #{__method__} - request has been queued.")
        end
      end
    end
  end
end
