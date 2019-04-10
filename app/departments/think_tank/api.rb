# frozen_string_literal: true

require 'singleton'
require_relative './services/analysis.rb'
require_relative './services/intelligence.rb'
require_relative './services/validation.rb'

##
# Unites three main responsibilities of Observer:
# intelligence, interpretation, data and cooperation between previous three and View controllers,
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

      # Starts the gathering of the intelligence data on a particular {FriendlyResource}.
      # @param [Integer] id {FriendlyResource} id.
      # @return [Void]
      def start_monitoring(id)
        Services::Validation.instance.id?(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.")
        friendly_resource = Archive::Api.instance.friendly_resource_by_id(id)
        Services::Intelligence.instance.gather_dos_intelligence(friendly_resource.ip_address)
      end

      # Stops the gathering of the intelligence data on a particular {FriendlyResource}.
      # @param [Integer] id {FriendlyResource} id.
      # @return [Void]
      def stop_monitoring(id)
        Services::Validation.instance.id?(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{id}")
        friendly_resource = Departments::Archive::Api.instance.friendly_resource_by_id(id)
        Services::Intelligence.instance.stop_dos_intelligence_gathering(friendly_resource.ip_address)
      end

      # Initiates interpretation of the latest intelligence data for a {FriendlyResource}.
      # Intelligence data is related to ICMP flood analysis.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Hash] data Intelligence data, related to ICMP Flood analysis.
      # @return [Void]
      def analyze_icmp_dos_intelligence_data(ip, data)
        Services::Validation.instance.ip_address?(ip)
        Services::Validation.instance.dos_icmp_intelligence_data?(data)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}, #{data}")
        query = Departments::Shared::AnalysisQuery.new(ip, Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT)
        Services::Analysis.instance.analyze(query, data)
      end

      # Returns {CybreReport} objects in a format that is parsable for a graph.
      # @param [Symbol] type {CyberReport} type, i.e. {Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Integer] page Page starts from 1.
      # @param [Integer] page_size Size of a single page.
      # @return [Array<CyberReport>]
      def latest_cyber_reports_graph(type, ip, page, page_size)
        Services::Validation.instance.cyper_report_type?(type)
        Services::Validation.instance.ip_address?(ip)
        Services::Validation.instance.page?(page)
        Services::Validation.instance.page_size?(page_size)
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

      # Indicates if the collection of intelligence data for ICMP flood attack analysis is still needed.
      # @param [Integer] ip Numerical representation of {FriendlyResource} ip address.
      # @return [Boolean]
      def continue_icmp_dos_intelligence_collection?(ip)
        Services::Validation.instance.ip_address?(ip)
        begin
          redis_client = Services::Redis.instance.client
          raw_cached_data = redis_client.get(ip.to_s)
          raw_cached_data ||= '{}'
          cached_data = JSON.parse(raw_cached_data)
          collect_formats = []
          collect_formats = cached_data['collect_formats'] if cached_data.key?('collect_formats')
          collect_formats.include?(Shared::IntelligenceFormat::DOS_ICMP)
        rescue StandardError
          false
        end
      end
    end
  end
end
