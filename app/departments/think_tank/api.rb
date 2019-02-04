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
    end
  end
end
