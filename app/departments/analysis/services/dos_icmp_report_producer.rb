# frozen_string_literal: true

require 'singleton'

module Departments
  module Analysis
    ##
    # Any long / supporting implementations that are used in {Departments::Analysis::Api}
    # are under this module.
    module Services
      ##
      # Has access to {Workers::Analysis::Dos::Icmp::CyberReportProducer}.
      class DosIcmpCyberReport
        include Singleton

        # Queues a job for a production of {Dos::IcmpFloodReport}.
        # @param [Integer] ip {FriendlyResource} ip address. Numerical representation.
        # @param [Hash] data Intelligence data for the production of a {Dos::IcmpFloodReport}.
        # @return [Void]
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
