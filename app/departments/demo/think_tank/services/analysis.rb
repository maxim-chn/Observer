# frozen_string_literal: true

require 'singleton'

module Departments
  module Demo
    module ThinkTank
      module Services
        ##
        # Consumes [AnalysisApi].
        class Analysis
          include Singleton

          # Consumes [AnalysisApi] to start production of DoS [CyberReports]s.
          # +ip+ - friendly resource ip.
          def analyze_dos_intelligence(ip)
            Rails.logger.info("#{self.class.name} - #{__method__} - IP : #{ip}")
            analysis_department_api = Departments::Demo::Analysis::Api.instance
            Departments::Demo::Shared::AnalysisType.dos_formats.each do |analysis_format|
              query = Departments::Demo::Shared::AnalysisQuery.new(ip, analysis_format)
              analysis_department_api.produce_interpretation_data(query)
            end
          end

          # Consumes [AnalysisApi] to stop production of DoS [CyberReports]s.
          # +ip+ - friendly resource ip.
          def stop_dos_intelligence_analysis(ip)
            Rails.logger.info("#{self.class.name} - #{__method__} - IP : #{ip}")
            analysis_department_api = Departments::Demo::Analysis::Api.instance
            Departments::Demo::Shared::AnalysisType.dos_formats.each do |analysis_format|
              query = Departments::Demo::Shared::AnalysisQuery.new(ip, analysis_format)
              analysis_department_api.stop_interpretation_data_production(query)
            end
          end
        end
      end
    end
  end
end
