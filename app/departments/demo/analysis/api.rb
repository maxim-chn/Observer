# frozen_string_literal: true

require 'singleton'
require_relative './services/dos_icmp_report_producer.rb'

module Departments
  module Demo
    module Analysis
      ##
      # [API] for consumption by other Observer modules.
      # It allows to operate analysis services,
      # i.e. queue particular [CyberReport] production.
      class Api
        include Singleton

        # Will queue a job for a relevant [CyberReport] producer.
        # +query+ - [AnalysisQuery] object. Must have:
        # * +friendly_resource_ip+ - ip of a monitored resource.
        # * +analysis_type+ - to know which worker to use.
        # +intelligence_data+ - intelligence collected by [FieldAgent].
        def request_cyber_report(query, intelligence_data)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{query.inspect}")
          case query.analysis_type
          when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            Services::DosIcmpCyberReport.instance.queue_dos_icmp_report(
              query.friendly_resource_ip,
              intelligence_data
            )
          end
        end
      end
    end
  end
end
