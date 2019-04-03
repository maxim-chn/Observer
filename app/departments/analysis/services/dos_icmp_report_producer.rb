# frozen_string_literal: true

require 'singleton'
require_relative './validation'

module Departments
  module Analysis
    ##
    # Supporting implementations for the methods in {Departments::Analysis::Api}.
    module Services
      ##
      # Has access to {Workers::Analysis::Dos::Icmp::CyberReportProducer}.
      class DosIcmpCyberReport
        include Singleton

        # Queues a job for a production of a {Dos::IcmpFloodReport}.
        # @param [Integer] ip {FriendlyResource} ip address.
        # @param [Hash] data Intelligence data for the production of a {Dos::IcmpFloodReport}.
        # @return [Void]
        def queue_dos_icmp_report(ip, data)
          Services::Validation.instance.ip_address?(data)
          Services::Validation.instance.intelligence_data?(data)
          Rails.logger.debug("#{self.class.name} - #{__method__} - #{ip}, #{data}")
          Workers::Analysis::Dos::Icmp::CyberReportProducer.perform_async(
            ip,
            Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
            data
          )
        end
      end
    end
  end
end
