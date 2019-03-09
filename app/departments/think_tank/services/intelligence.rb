# frozen_string_literal: true

require 'singleton'

module Departments
  module ThinkTank
    module Services
      ##
      # Consumes {Departments::Intelligence::Api}.
      class Intelligence
        include Singleton

        # @param [Integer] ip {FriendlyResource} ip address. Numerical representation.
        # @return [Void]
        def gather_dos_intelligence(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - IP : #{ip}")
          intelligence_department_api = Departments::Intelligence::Api.instance
          Departments::Shared::IntelligenceFormat.dos_formats.each do |dos_format|
            query = Departments::Shared::IntelligenceQuery.new(ip, dos_format)
            intelligence_department_api.start_intelligence_gathering(query)
          end
        end

        # @param [Integer] ip {FriendlyResource} ip address. Numerical representation.
        # @return [Void]
        def stop_dos_intelligence_gathering(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - IP : #{ip}")
          intelligence_department_api = Departments::Intelligence::Api.instance
          Departments::Shared::IntelligenceFormat.dos_formats.each do |dos_format|
            query = Departments::Shared::IntelligenceQuery.new(ip, dos_format)
            intelligence_department_api.stop_intelligence_gathering(query)
          end
        end
      end
    end
  end
end
