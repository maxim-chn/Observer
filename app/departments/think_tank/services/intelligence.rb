# frozen_string_literal: true

require 'singleton'

module Departments
  module ThinkTank
    module Services
      ##
      # Consumes {Departments::Intelligence::Api}.
      class Intelligence
        include Singleton

        # @param [Integer] ip {FriendlyResource} ip address.
        # @return [Void]
        def gather_dos_intelligence(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.")
          Shared::IntelligenceFormat.dos_formats.each do |f|
            query = Shared::IntelligenceQuery.new(ip, f)
            Departments::Intelligence::Api.instance.start_intelligence_gathering(query)
          end
        end

        # @param [Integer] ip {FriendlyResource} ip address.
        # @return [Void]
        def gather_code_injection_intelligence(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.")
          Shared::IntelligenceFormat.code_injection_formats.each do |f|
            query = Shared::IntelligenceQuery.new(ip, f)
            Departments::Intelligence::Api.instance.start_intelligence_gathering(query)
          end
        end

        # @param [Integer] ip {FriendlyResource} ip address. Numerical representation.
        # @return [Void]
        def stop_dos_intelligence_gathering(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.")
          Shared::IntelligenceFormat.dos_formats.each do |f|
            query = Shared::IntelligenceQuery.new(ip, f)
            Departments::Intelligence::Api.instance.stop_intelligence_gathering(query)
          end
        end

        # @param [Integer] ip {FriendlyResource} ip address. Numerical representation.
        # @return [Void]
        def stop_code_injection_intelligence_gathering(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.")
          Shared::IntelligenceFormat.code_injection_formats.each do |f|
            query = Shared::IntelligenceQuery.new(ip, f)
            Departments::Intelligence::Api.instance.stop_intelligence_gathering(query)
          end
        end

        # Singnals if a collection for the {Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT}
        # intelligence is still required.
        # @param [Integer] ip {FriendlyResource} ip address.
        # @return [Boolean]
        def icmp_dos_intelligence_collection?(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.")
          query = Shared::IntelligenceQuery.new(ip, Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT)
          Departments::Intelligence::Api.instance.continue_collection?(query)
        end

        # Singnals if a collection for the {Shared::IntelligenceFormat::SQL_INJECTION_CYBER_REPORT}
        # intelligence is still required.
        # @param [Integer] ip {FriendlyResource} ip address.
        # @return [Boolean]
        def sql_injection_intelligence_collection?(ip)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{ip}.")
          query = Shared::IntelligenceQuery.new(ip, Shared::IntelligenceFormat::SQL_INJECTION_CYBER_REPORT)
          Departments::Intelligence::Api.instance.continue_collection?(query)
        end
      end
    end
  end
end
