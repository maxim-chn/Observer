# frozen_string_literal: true

require 'singleton'
require_relative './services/analysis.rb'
require_relative './services/intelligence.rb'

##
# Unites three main responsibilities of Observer:
# intelligence, interpretation, data, cooperation between previous three and View controllers,
# i.e. {FriendlyResourcesController}.
# Each responsibility has its own module:
# - {Departments::Analysis} - handles interpretation of intelligence.
# - {Departments::Archive} - handles data.
# - {Departments::Intelligence} - handles intelligence.
# - {Departments::Shared} - holds methods or values common to a group of departments.
# - {Departments::ThinkTank} - a bridge between {Departments::Intelligence},
#   {Departments::Analysis} and View controllers.
module Departments
  ##
  # Holds logic that connects between View controllers, i.e. {FriendlyResourcesController}, and
  # {Departments::Intelligence}, {Departments::Analysis}.
  module ThinkTank
    ##
    # Methods that are consumed by other modules / classes, i.e. {FriendlyResourcesController}.
    class Api
      include Singleton

      # Sets up gathering of intelligence and its interpretation for a particular {FriendlyResource}.
      # @param [Integer] id {FriendlyResource} id in the database.
      # @return [Void]
      def start_monitoring(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - id : #{id}")
        archive_api = Departments::Archive::Api.instance
        friendly_resource = archive_api.friendly_resource_by_id(id)
        intelligence_services = Services::Intelligence.instance
        intelligence_services.gather_dos_intelligence(friendly_resource.ip_address)
      end

      # Stops gathering of intelligence and its interpretation for a particular {FriendlyResource}.
      # @param [Integer] id {FriendlyResource} id in the database.
      # @return [Void]
      def stop_monitoring(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - id : #{id}")
        archive_api = Departments::Archive::Api.instance
        friendly_resource = archive_api.friendly_resource_by_id(id)
        intelligence_services = Services::Intelligence.instance
        intelligence_services.stop_dos_intelligence_gathering(friendly_resource.ip_address)
      end

      # Initiates interpretation of a latest intelligence data for a {FriendlyResource}.
      # Intelligence data is connected to ICMP flood analysis.
      # @param [Integer] ip {FriendlyResource} ip address. Numeric representation.
      # @param [Hash] data Intelligence data, connected to ICMP Flood analysis.
      # @return [Void]
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

      # Indicates if collection of intelligence data for ICMP flood attack analysis is still needed
      # @param [Integer] ip Numerical representation of {FriendlyResource} ip address.
      # @return [Boolean]
      def continue_icmp_dos_intelligence_collection?(ip)
        begin
          redis_client = Services::Redis.instance.get_client
          raw_cached_data = client.get(ip.to_s)
          raw_cached_data ||= '{}'
          cached_data = JSON.parse(raw_cached_data)
          collect_formats = []
          if cached_data.key?('collect_formats')
            collect_formats = cached_data['collect_formats']
          end
          return collect_formats.include?(Shared::IntelligenceFormat::DOS_ICMP)
        rescue StandardError => e
          return false
        end
      end
    end
  end
end
