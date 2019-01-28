# frozen_string_literal: true

require 'singleton'
require_relative './services/dos_interpretation.rb'

module Departments
  module Demo
    module Archive
      ##
      # This is [ArchiveApi] that is consumed by other parts of [Observer].
      # For example, [FriendlyResourceController].
      class Api
        include Singleton

        # [FriendlyResource] related methods.
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

        # [CyberReport] related methods.
        def all_cyber_reports_by_friendly_resource(id, page, page_size)
          result = []
          friendly_resource = get_friendly_resource_by_id(id)
          if friendly_resource
            result = friendly_resource.dos_icmp_interpretation_data.paginate(
              page: page,
              per_page: page_size
            )
          end
          result
        end

        def cyber_report_by_id_and_type(id, type)
          cyber_report = nil
          case type
          when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            icmp_interp_data_service = Services::DosInterpretations.instance
            cyber_report = icmp_interp_data_service.icmp_flood_report_by_id(id)
          end
          cyber_report
        end

        # +ip+ - [FriendlyResource] IP.
        # +type+ - name of class that extends [CyberReport].
        # +opts+ - [Hash] with additional custom attributes:
        # * +opts[:seasonal_index]+ - an attribute for [IcmpFloodReport].
        def cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
            ip,
            type,
            opts
          )
          friendly_resource = friendly_resource_by_ip(ip)
          if friendly_resource
            result = nil
            case type
            when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
              icmp_interp_data_service = Services::DosInterpretations.instance
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

        # +ip+ - [FriendlyResource] IP.
        # +type+ - name of class that extends [CyberReport].
        # +opts+ - [Hash] with mandatory values for new object initialization:
        # * +opts[:seasonal_index]+ - a mandatory attribute for [IcmpFloodReport].
        def new_cyber_report_object_for_friendly_resource(ip, type, opts)
          friendly_resource = get_friendly_resource_by_ip(ip)
          if friendly_resource
            result = nil
            case type
            when Departments::Demo::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
              icmp_interp_data_service = Services::DosInterpretations.instance
              result = icmp_interp_data_service.new_report_object(
                opts[:seasonalIndex]
              )
              friendlyResource.dos_icmp_interpretation_data << result if result
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
end
