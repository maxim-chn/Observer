# frozen_string_literal: true

require 'singleton'

module Departments
  module Demo
    module Analysis
      module Services
        ##
        # Has access to [IcmpCyberReportProducer].
        class DosIcmpCyberReport
          include Singleton

          # Will queue a job for production of [DosIcmpCyberReport].
          # +ip+ - [Friendly Resource] IP address.
          # +intelligence_data+ - [JSON] with intelligence data collected by [FieldAgent].
          def queue_dos_icmp_report(ip, intelligence_data)
            Rails.logger.debug(
              "#{self.class.name} - #{__method__} - #{query.inspect}\n \
              #{intelligence_data.inspect}"
            )
            Workers::Demo::Analysis::Dos::Icmp::CyberReportProducer.perform_async(
              ip,
              intelligence_data
            )
            Rails.logger.debug("#{self.class.name} - #{__method__} - request has been queued.")
          end
        end
      end
    end
  end
end
