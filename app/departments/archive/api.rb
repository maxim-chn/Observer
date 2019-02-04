# frozen_string_literal: true

require 'singleton'
require_relative './services/icmp_flood_report.rb'

module Departments
  module Archive
    ##
    # API that is consumed by other modules.
    class Api
      include Singleton

      # FriendlyResource related methods.
      def all_friendly_resources(page, page_size)
        FriendlyResource.paginate(page: page, per_page: page_size)
      end

      def friendly_resource_by_cyber_report(cyber_report)
        cyber_report.friendly_resource
      end

      def friendly_resource_by_id(id)
        FriendlyResource.find(id)
      end

      def friendly_resource_by_ip(ip)
        FriendlyResource.find_by(ip_address: ip)
      end

      # CyberReport related methods.
      def all_cyber_reports_by_friendly_resource(id, page, page_size)
        result = []
        friendly_resource = friendly_resource_by_id(id)
        if friendly_resource
          result = friendly_resource.latest_cyber_reports
        end
        result
      end

      def cyber_report_by_id_and_type(id, type)
        cyber_report = nil
        case type
        when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
          icmp_interp_data_service = Services::IcmpFloodReport.instance
          cyber_report = icmp_interp_data_service.icmp_flood_report_by_id(id)
        end
        cyber_report
      end

      # [ip] Integer.
      #      FriendlyResource ip.
      # [type] Enum.
      #        CyberReport type.
      # [opts] Hash.
      #        Additional custom attributes:
      #         * :seasonal_index - an attribute for Dos::IcmpFloodReport.
      def cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
          ip,
          type,
          opts
        )
        friendly_resource = friendly_resource_by_ip(ip)
        if friendly_resource
          result = nil
          case type
          when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            icmp_interp_data_service = Services::IcmpFloodReport.instance
            result = icmp_interp_data_service
                     .latest_report_by_friendly_resource_id_and_seasonal_index(
                       friendly_resource.id,
                       opts[:seasonal_index]
                     )
          end
          return result
        end
        throw Exception.new("#{self.class.name} - #{__method__} - no friendly resource\
          for ip : #{ip}.")
      end

      # [ip] Integer.
      #      FriendlyResource ip.
      # [type] Enum.
      #        CyberReport type.
      # [opts] Hash.
      #        Additional custom attributes:
      #         * :seasonal_index - a mandatory attribute for Dos::IcmpFloodReport.
      def new_cyber_report_object_for_friendly_resource(ip, type, opts)
        friendly_resource = friendly_resource_by_ip(ip)
        if friendly_resource
          result = nil
          case type
          when Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            icmp_interp_data_service = Services::IcmpFloodReport.instance
            result = icmp_interp_data_service.new_report_object(
              opts[:seasonal_index]
            )
            friendly_resource.icmp_flood_report << result if result
            return result
          end
        end
        throw Exception.new("#{self.class.name} - #{__method__} - no friendly resource\
          for ip : #{ip}.")
      end

      def persist_cyber_report(report)
        report.save
      end
    end
  end
end
