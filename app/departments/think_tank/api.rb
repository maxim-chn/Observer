# frozen_string_literal: true

require 'singleton'
require_relative './services/analysis.rb'
require_relative './services/intelligence.rb'
require_relative './services/validation.rb'

##
# Unites three main responsibilities of the {https://github.com/Z0neNp/Observer Observer}:
# intelligence, interpretation, data, cooperation between previous three and
# {https://guides.rubyonrails.org/action_view_overview.html View} controllers.
# Each responsibility has its own module:
# - {Departments::Analysis} - handles the interpretation of the intelligence data.
#   It consumes the following workers: {Workers::Analysis::CodeInjection::Sql::CyberReportProducer},
#   {Workers::Analysis::Dos::Icmp::CyberReportProducer}.
# - {Departments::Archive} - handles the data.
#   It consumes the {https://guides.rubyonrails.org/active_record_basics.html Models}, i.e. {FriendlyResource}.
# - {Departments::Intelligence} - handles the intelligence data gathering. It consumes the following workers:
#   {Workers::Intelligence::AddCollectionFormat}, {Workers::Intelligence::RemoveCollectionFormat}.
# - {Departments::Shared} - holds the methods / values that are common to the {Departments}.
# - {Departments::ThinkTank} - connects between
#   the {Departments::Intelligence}, {Departments::Analysis} and
#   {https://guides.rubyonrails.org/action_view_overview.html View} controllers.
module Departments
  ##
  # Holds the logic that connects between the
  # {https://guides.rubyonrails.org/action_view_overview.html View} controllers,
  # i.e. {FriendlyResourcesController}, {Departments::Intelligence} and {Departments::Analysis}.
  module ThinkTank
    ##
    # Methods that are consumed by other modules / classes, i.e. {FriendlyResourcesController}.
    class Api
      include Singleton

      # Initiates the interpretation of the latest intelligence data about a {FriendlyResource}.
      # Intelligence data is related to the {https://en.wikipedia.org/wiki/Ping_flood ICMP flood} analysis.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Hash] data Intelligence data.
      # @return [Void]
      def analyze_icmp_dos_intelligence_data(ip, data)
        Services::Validation.instance.ip_address?(ip)
        Services::Validation.instance.dos_icmp_intelligence_data?(data)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}, #{data}.") if Rails.env.development?
        query = Shared::AnalysisQuery.new(ip, Shared::AnalysisType::ICMP_DOS_CYBER_REPORT)
        Services::Analysis.instance.analyze(query, data)
      end

      # Initiates an interpretation of the latest intelligence data about a {FriendlyResource}.
      # Intelligence data is related to the {https://en.wikipedia.org/wiki/SQL_injection SQL injection} analysis.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Hash] data Intelligence data.
      # @return [Void]
      def analyze_sql_injection_intelligence_data(ip, data)
        Services::Validation.instance.ip_address?(ip)
        Services::Validation.instance.sql_injection_intelligence_data?(data)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}, #{data}.") if Rails.env.development?
        query = Shared::AnalysisQuery.new(ip, Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT)
        Services::Analysis.instance.analyze(query, data)
      end

      # Starts the gathering of the intelligence data about a {FriendlyResource}.
      # @param [Integer] id {FriendlyResource} id.
      # @return [Void]
      def start_monitoring(id)
        Services::Validation.instance.id?(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.") if Rails.env.development?
        friendly_resource = Archive::Api.instance.friendly_resource_by_id(id)
        Services::Intelligence.instance.gather_dos_intelligence(friendly_resource.ip_address)
        Services::Intelligence.instance.gather_code_injection_intelligence(friendly_resource.ip_address)
      end

      # Stops the gathering of the intelligence data about a {FriendlyResource}.
      # @param [Integer] id {FriendlyResource} id.
      # @return [Void]
      def stop_monitoring(id)
        Services::Validation.instance.id?(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.") if Rails.env.development?
        friendly_resource = Archive::Api.instance.friendly_resource_by_id(id)
        Services::Intelligence.instance.stop_dos_intelligence_gathering(friendly_resource.ip_address)
        Services::Intelligence.instance.stop_code_injection_intelligence_gathering(friendly_resource.ip_address)
      end

      # Returns {CyberReport} objects in a format that is parsable as a graph.
      # @param [Symbol] type {CyberReport} type, i.e. {Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Integer] page
      # @param [Integer] page_size
      # @return [Array<CyberReport>]
      def latest_cyber_reports_graph(type, ip, page, page_size)
        Services::Validation.instance.cyper_report_type?(type)
        Services::Validation.instance.ip_address?(ip)
        Services::Validation.instance.page?(page)
        Services::Validation.instance.page_size?(page_size)
        if Rails.env.development?
          Rails.logger.info("#{self.class.name} - #{__method__} - #{type}, #{ip}, #{page}, #{page_size}.")
        end
        archive_api = Archive::Api.instance
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

      # Is the collection of the intelligence data for the
      # {https://en.wikipedia.org/wiki/Ping_flood ICMP flood} attack analysis needed?
      # @param [Integer] ip {FriendlyResource} ip address.
      # @return [Boolean]
      def icmp_dos_intelligence_collection?(ip)
        Services::Validation.instance.ip_address?(ip)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.") if Rails.env.development?
        Services::Intelligence.instance.icmp_dos_intelligence_collection?(ip)
      end

      # Is the collection of the intelligence data for the
      # {https://en.wikipedia.org/wiki/SQL_injection SQL injection} attack analysis needed?
      # @param [Integer] ip {FriendlyResource} ip address.
      # @return [Boolean]
      def sql_injection_intelligence_collection?(ip)
        Services::Validation.instance.ip_address?(ip)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.") if Rails.env.development?
        Services::Intelligence.instance.sql_injection_intelligence_collection?(ip)
      end
    end
  end
end
