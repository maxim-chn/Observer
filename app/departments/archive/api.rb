# frozen_string_literal: true

require 'singleton'
require_relative './services/validation.rb'
require_relative './services/icmp_flood_report.rb'
require_relative './services/sql_injection_report.rb'
require_relative './services/query_helper'

module Departments
  ##
  # A module that has direct access to models, i.e. {FriendlyResource}.
  module Archive
    ##
    # Methods that are consumed by the other modules, i.e.
    # {Workers::Analysis::CodeInjection::Sql::CyberReportProducer}.
    class Api
      include Singleton

      # @param [Integer] page
      # @param [Integer] page_size
      # @return [Array<FriendlyResource>]
      def friendly_resources(page, page_size)
        Services::Validation.instance.page?(page)
        Services::Validation.instance.page_size?(page_size)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{page}, #{page_size}.") if Rails.env.development?
        records_to_skip = Services::QueryHelper.instance.records_to_skip(page, page_size)
        FriendlyResource.order('created_at desc').limit(page_size).offset(records_to_skip).to_a
      end

      # Total amount of {FriendlyResource} records in the database.
      # @return [Integer]
      def friendly_resources_count
        Rails.logger.info("#{self.class.name} - #{__method__}.") if Rails.env.development?
        FriendlyResource.count
      end

      # @param [CyberReport] cyber_report For example, {Dos::IcmpFloodReport}.
      # @return [FriendlyResource]
      def friendly_resource_by_cyber_report(cyber_report)
        Services::Validation.instance.cyber_report?(cyber_report)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{cyber_report.inspect}.") if Rails.env.development?
        cyber_report.friendly_resource
      end

      # @param [Integer] id {FriendlyResource} id in the database.
      # @return [FriendlyResource]
      def friendly_resource_by_id(id)
        Services::Validation.instance.id?(id)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.") if Rails.env.development?
        FriendlyResource.find(id)
      end

      # @param [Integer] ip_address {FriendlyResource} ip address.
      # @return [FriendlyResource]
      def friendly_resource_by_ip(ip_address)
        Services::Validation.instance.friendly_resource_ip_address?(ip_address)
        Services::Validation.instance.integer?(ip_address)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip_address}.") if Rails.env.development?
        FriendlyResource.find_by(ip_address: ip_address)
      end

      # Initiates a new {FriendlyResource} object. It is not persisted in the database yet.
      # @param [String] name {FriendlyResource} name.
      # @param [Object] ip_address {FriendlyResource} ip address. It can be a [String] or an [Integer].
      # @return [FriendlyResource]
      def new_friendly_resource(name, ip_address)
        Services::Validation.instance.friendly_resource_name?(name)
        Services::Validation.instance.friendly_resource_ip_address?(ip_address)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{name}, #{ip_address}.") if Rails.env.development?
        if ip_address.class == String
          if ip_address.match?(/^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$/)
            ip_address = IPAddr.new(ip_address).to_i
          elsif ip_address.match?(/^[0-9]*$/)
            ip_address = ip_address.to_i
          end
        end
        FriendlyResource.new(name: name, ip_address: ip_address)
      end

      # Initiates a new {FriendlyResource} object. It is not persisted in the database yet.
      # @param [Hash] friendly_resource Contains fields and values for {FriendlyResource}.
      # @return [FriendlyResource]
      def new_friendly_resource_from_hash(friendly_resource)
        Services::Validation.instance.hash?(friendly_resource)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{friendly_resource}.") if Rails.env.development?
        new_friendly_resource(friendly_resource['name'], friendly_resource['ip_address'])
      end

      # Initiates a new {FriendlyResource} object. It is not persisted in the database yet.
      # @return [FriendlyResource]
      def new_empty_friendly_resource
        Rails.logger.info("#{self.class.name} - #{__method__}.") if Rails.env.development?
        FriendlyResource.new
      end

      # Will persist the {FriendlyResource} object in the database.
      # @param [FriendlyResource] friendly_resource {FriendlyResource}.
      # @return [Void]
      def persist_friendly_resource(friendly_resource)
        Services::Validation.instance.friendly_resource?(friendly_resource)
        if Rails.env.development?
          debug_message = "#{self.class.name} - #{__method__} - #{friendly_resource.inspect}."
          Rails.logger.info(debug_message)
        end
        friendly_resource.save
      end

      # Total amount of {CyberReport} records in the database by a report type.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Symbol] type For example, {Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
      # @return [Integer]
      def cyber_reports_count(ip, type)
        Services::Validation.instance.friendly_resource_ip_address?(ip)
        Services::Validation.instance.cyper_report_type?(type)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}, #{type}.") if Rails.env.development?
        result = 0
        friendly_resource = friendly_resource_by_ip(ip)
        if friendly_resource
          case type
          when Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            result = Services::IcmpFloodReport.instance.count_records(friendly_resource.id)
          when Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
            result = Services::SqlInjectionReport.instance.count_records(friendly_resource.id)
          end
        end
        result
      end

      # Retrieves in DESC order, according to the creation date.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Symbol] type For example, {Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
      # @param [Integer] page Starts at 1.
      # @param [Integer] page_size
      # @return [Array<CyberReport>]
      def cyber_reports_by_friendly_resource_ip_and_type(ip, type, page, page_size)
        Services::Validation.instance.friendly_resource_ip_address?(ip)
        Services::Validation.instance.cyper_report_type?(type)
        Services::Validation.instance.page?(page)
        Services::Validation.instance.page_size?(page_size)
        if Rails.env.development?
          debug_message = "#{self.class.name} - #{__method__} - #{ip}, #{type}, #{page}, #{page_size}."
          Rails.logger.info(debug_message)
        end
        result = []
        ip = IPAddr.new(ip).to_i if ip.class == String
        friendly_resource = friendly_resource_by_ip(ip)
        if friendly_resource
          case type
          when Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            result = Services::IcmpFloodReport.instance.latest_reports_by_friendly_resource_id(
              friendly_resource.id,
              page,
              page_size
            )
          when Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
            result = Services::SqlInjectionReport.instance.latest_reports_by_friendly_resource_id(
              friendly_resource.id,
              page,
              page_size
            )
          end
        end
        result
      end

      # @param [Integer] id {CyberReport} id in the database.
      # @param [Symbol] type For example, {Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
      # @return [CyberReport]
      def cyber_report_by_id_and_type(id, type)
        Services::Validation.instance.integer?(id)
        Services::Validation.instance.cyper_report_type?(type)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{id}, #{type}.") if Rails.env.development?
        cyber_report = nil
        case type
        when Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
          cyber_report = Services::IcmpFloodReport.instance.report_by_id(id)
        when Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
          cyber_report = Services::SqlInjectionReport.instance.report_by_id(id)
        end
        cyber_report
      end

      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [Symbol] type For example, {Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
      # @param [Hash] opts Additional custom attributes:
      #   * 'seasonal_index' [Integer] a mandatory attribute for {Dos::IcmpFloodReport}.
      # @return {CyberReport}
      def cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(ip, type, opts)
        Services::Validation.instance.friendly_resource_ip_address?(ip)
        Services::Validation.instance.cyper_report_type?(type)
        Services::Validation.instance.custom_attributes?(opts)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}, #{type}, #{opts}.") if Rails.env.development?
        ip = IPAddr.new(ip).to_i if ip.class == String
        friendly_resource = friendly_resource_by_ip(ip)
        if friendly_resource
          result = nil
          case type
          when Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            Services::Validation.instance.seasonal_index_in_opts?(opts)
            result = Services::IcmpFloodReport.instance.latest_report_by_friendly_resource_id_and_seasonal_index(
              friendly_resource.id,
              opts['seasonal_index']
            )
          end
          return result
        end
        error_message = "#{self.class.name} - #{__method__} - no friendly resource for ip : #{ip}."
        throw Exception.new(error_message)
      end

      # Initializes a {CyberReport} instance, i.e. {Dos::IcmpFloodReport}.
      # @param [Integer] ip {FriendlyResource} ip address.
      # @param [AnalysisType] type For example, {Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
      # @param [Hash] opts Additional custom attributes:
      #   * 'seasonal_index' [Integer] a mandatory attribute for {Dos::IcmpFloodReport}.
      # @return {CyberReport}
      def new_cyber_report_object_for_friendly_resource(ip, type, opts = {})
        Services::Validation.instance.friendly_resource_ip_address?(ip)
        Services::Validation.instance.cyper_report_type?(type)
        Services::Validation.instance.custom_attributes?(opts)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}, #{type}, #{opts}.") if Rails.env.development?
        ip = IPAddr.new(ip).to_i if ip.class == String
        friendly_resource = friendly_resource_by_ip(ip)
        if friendly_resource
          result = nil
          case type
          when Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
            Services::Validation.instance.seasonal_index_in_opts?(opts)
            result = Services::IcmpFloodReport.instance.new_report_object(
              opts['seasonal_index']
            )
            friendly_resource.icmp_flood_report << result if result
            return result
          when Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
            result = Services::SqlInjectionReport.instance.new_report_object
            friendly_resource.sql_injection_report << result if result
            return result
          end
        end
        error_message = "#{self.class.name} - #{__method__} - no friendly resource for ip : #{ip}."
        throw Exception.new(error_message)
      end

      # @param [CyberReport] cyber_report One of the {CyberReport} instances,
      # i.e. {Dos::IcmpFloodReport}
      def persist_cyber_report(cyber_report)
        Services::Validation.instance.cyber_report?(cyber_report)
        Rails.logger.info("#{self.class.name} - #{__method__} - #{cyber_report.inspect}.") if Rails.env.development?
        cyber_report.save
      end

      # @return [Array<Symbol>]
      def cyber_report_types
        Rails.logger.info("#{self.class.name} - #{__method__}.") if Rails.env.development?
        Shared::AnalysisType.formats
      end
    end
  end
end
