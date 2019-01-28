# frozen_string_literal: true

require 'singleton'

module Departments
  module Demo
    module ThinkTank
      module Services
        ##
        # Consumes [IntelligenceApi].
        class Intelligence
          include Singleton

          # Consume one of [IntelligenceApi] methods to pass to [FieldAgent],
          # what we data we need to be collected.
          # +ip+ - friendly resource ip.
          def gather_dos_intelligence(ip)
            Rails.logger.info("#{self.class.name} - #{__method__} - IP : #{ip}")
            intelligence_department_api = Departments::Demo::Intelligence::Api.instance
            Departments::Demo::Shared::IntelligenceFormat.dos_formats.each do |dos_format|
              query = Departments::Demo::Shared::IntelligenceQuery.new(ip, dos_format)
              intelligence_department_api.start_intelligence_gathering(query)
            end
          end

          # Consume one of [IntelligenceApi] methods to pass to [FieldAgent],
          # what we data we do not need to be collected.
          # +ip+ - friendly resource ip.
          def stop_dos_intelligence_gathering(ip)
            Rails.logger.info("#{self.class.name} - #{__method__} - IP : #{ip}")
            intelligence_department_api = Departments::Demo::Intelligence::Api.instance
            Departments::Demo::Shared::IntelligenceFormat.dos_formats.each do |dos_format|
              query = Departments::Demo::Shared::IntelligenceQuery.new(ip, dos_format)
              intelligence_department_api.stop_intelligence_gathering(query)
            end
          end
        end
      end
    end
  end
end
