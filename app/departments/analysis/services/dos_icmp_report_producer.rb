# frozen_string_literal: true

require 'singleton'
require_relative './validation'

module Departments
  module Analysis
    ##
    # Supporting methods for the {Departments::Analysis} module.
    module Services
      ##
      # Consumes the {Workers::Analysis::Dos::Icmp::CyberReportProducer}.
      class DosIcmpCyberReport
        include Singleton

        # Queues a job for a production of a {Dos::IcmpFloodReport}.
        # @param [Integer] ip {FriendlyResource} ip address.
        # @param [Hash] data Intelligence data.
        # @return [Void]
        def queue_a_report(ip, data)
          Services::Validation.instance.ip_address?(ip)
          Services::Validation.instance.dos_icmp_intelligence_data?(data)
          Rails.logger.debug("#{self.class.name} - #{__method__} - #{ip}, #{data}.") if Rails.env.development?
          Workers::Analysis::Dos::Icmp::CyberReportProducer.perform_async(
            ip,
            Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
            data,
            log: Rails.env.development?
          )
        end
      end
    end
  end
end
