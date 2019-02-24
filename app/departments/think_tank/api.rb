# frozen_string_literal: true

require 'singleton'
require_relative './services/analysis.rb'
require_relative './services/intelligence.rb'

module Departments
  module ThinkTank
    ##
    # API for consumption by other modules.
    class Api
      include Singleton

      # [id] Integer.
      #      FriendlyResource id in the database.
      # [return] Void.
      def start_monitoring(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - id : #{id}")
        archive_api = Departments::Archive::Api.instance
        friendly_resource = archive_api.friendly_resource_by_id(id)
        intelligence_services = Services::Intelligence.instance
        intelligence_services.gather_dos_intelligence(friendly_resource.ip_address)
      end

      # [id] Integer.
      #      FriendlyResource id in the database.
      # [return] Void.
      def stop_monitoring(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - id : #{id}")
        archive_api = Departments::Archive::Api.instance
        friendly_resource = archive_api.friendly_resource_by_id(id)
        intelligence_services = Services::Intelligence.instance
        intelligence_services.stop_dos_intelligence_gathering(friendly_resource.ip_address)
      end

      # [ip] Integer.
      #      FriendlyResource ip address.
      # [data] Hash.
      #        intelligence data.
      # [return] Void.
      def analyze_icmp_dos_intelligence_data(ip, data)
        query = Departments::Shared::AnalysisQuery.new(ip, Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT)
        Services::Analysis.instance.analyze(query, data)
      end

      # Will return cyber reports in format that is parsable for a graph.
      # @param [Symbol] type Type cyber report, i.e. {Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}
      # @param [Integer] ip Numerical representation of ip address of {FriendlyResource}.
      # @param [Integer] page Page starts from 1.
      # @param [Integer] page_size Size of a single page.
      # @return [Array<CyberReport>]
      def latest_cyber_reports_graph(type, ip, page, page_size)
        archive_api = Departments::Archive::Api.instance
        latest_cyber_reports = archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          ip,
          type,
          page,
          page_size
        )
        graph = []
        case type
        when Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
          graph << { name: 'confidence_band_upper_value', data: {} }
          graph << { name: 'actual_value', data: {} }
          hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
          latest_cyber_reports.each do |report|
            time_str = hw_forecasting_api.seasonal_index_reverse(report.seasonal_index.dup)
            graph[0][:data][time_str] = report.confidence_band_upper_value.dup
            graph[1][:data][time_str] = report.actual_value.dup
          end
        end
        graph
      end
    end
  end
end
