# frozen_string_literal: true

module Workers
  module Analysis
    module CodeInjection
      ##
      # Scopes workers that interpret intelligence related to ICMP flood attack.
      module Sql
        ##
        # Produces {CodeInjection::SqlInjectionReport}.
        class CyberReportProducer < Workers::WorkerWithRedis
          include Sidekiq::Worker
          sidekiq_options retry: false

          # Asynchronously creates {CodeInjection::SqlInjectionReport} if there is an attack.
          # Consumes {Departments::Archive::Api} to persist it.
          # @param [Integer] ip {FriendlyResource} ip address.
          # @param [Symbol] type Type of {CyberReport} to be created, i.e.
          # {Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT}.
          # @param [Hash<String, Object>] intelligence_data Contains one or both of the keys:
          #   * 'uris' A [Array<String>] with the uris from GET requests to a {FriendlyResource}.
          # @return [Void]
          def perform(ip, type, intelligence_data, log: true)
            logger.info("#{self.class.name} - #{__method__} - #{ip}, #{type}, #{intelligence_data}.") if log
            begin
              reason = ''
              intelligence_data['uris'].each do |uri|
                next_malicious_code = malicious_code(uri)
                reason += next_malicious_code if next_malicious_code
              end
              unless reason.empty?
                archive_api = Departments::Archive::Api.instance
                cyber_report = archive_api.new_cyber_report_object_for_friendly_resource(ip, type)
                cyber_report.reason = reason
                archive_api.persist_cyber_report(cyber_report)
                logger.info("#{self.class.name} - #{__method__} - persisted #{cyber_report.inspect}.")
              end
            rescue StandardError => e
              logger.error("#{self.class.name} - #{__method__} - failed - reason : #{e.message}.")
            end
          end

          private

          # @return [String]
          def malicious_code(text)
            text[/DROP DATABASE [a-z]+;/] if text
          end
        end
      end
    end
  end
end
