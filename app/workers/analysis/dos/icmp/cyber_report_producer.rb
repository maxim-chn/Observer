# frozen_string_literal: true

module Workers
  module Analysis
    module Dos
      ##
      # Scopes the workers that interpret the intelligence related to the
      # {https://en.wikipedia.org/wiki/Ping_flood ICMP flood} attack.
      module Icmp
        ##
        # Produces the {Dos::IcmpFloodReport}.
        class CyberReportProducer < Workers::Analysis::Dos::HoltWintersForecastingWorker
          include Sidekiq::Worker
          sidekiq_options retry: false

          # Asynchronously creates a {CyberReport}, i.e. {Dos::IcmpFloodReport}, object for the moment T.
          # Consumes {Departments::Archive::Api} to persist it.
          # @param [Integer] ip Numerical representation of {FriendlyResource} ip address.
          # @param [Symbol] type Type of {CyberReport} to be created, i.e.
          # {Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
          # @param [Hash<String, Object>] intelligence_data Contains keys:
          #   * 'incoming_req_count' Amount of incoming ICMP requests to a {FriendlyResource}.
          # @return [Void]
          def perform(ip, type, intelligence_data, log = false)
            logger.info("#{self.class.name} - #{__method__} - #{ip}, #{type}, #{intelligence_data}.") if log
            begin
              # In production, there should be no :seasonal_indices inside intelligence_data.
              # It is an ugly hack, to ease upon integration test. Sorry, could not think
              # of anything better :(
              indices = intelligence_data['seasonal_indices'] if intelligence_data['seasonal_indices']
              indices = seasonal_indices_for_holt_winters_calculation_step if indices.nil?
              logger.info("#{self.class.name} - #{__method__} - seasonal indices : #{indices}.") if log
              reports = cyber_reports_for_holt_winters_calculation_step(
                ip,
                type,
                indices
              )
              logger.info("#{self.class.name} - #{__method__} - cyber reports : #{reports}.") if log
              forecasting_step(
                reports[:prev_season],
                reports[:prev_season_next_step],
                reports[:last],
                reports[:latest],
                intelligence_data['incoming_req_count'],
                log
              )
              Departments::Archive::Api.instance.persist_cyber_report(reports[:latest])
              logger.info("#{self.class.name} - #{__method__} - persisted #{reports[:latest].inspect}.") if log
            rescue StandardError => e
              logger.error("#{self.class.name} - #{__method__} - failed - #{e.message}.")
            ensure
              client.quit unless client.nil?
            end
          end

          private

          # @return [Hash<Symbol, Integer>]
          def seasonal_indices_for_holt_winters_calculation_step
            indices = {}
            hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
            indices[:current] = hw_forecasting_api.seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
            indices[:previous] = hw_forecasting_api.prev_seasonal_index(
              Algorithms::HoltWintersForecasting::ICMP_FLOOD,
              indices[:current]
            )
            indices[:next] = hw_forecasting_api.next_seasonal_index(
              Algorithms::HoltWintersForecasting::ICMP_FLOOD,
              indices[:current]
            )
            indices
          end

          # @param [Integer] ip Numerical representation of {FriendlyResource} ip address.
          # @param [Symbol] type {CyberReport} type, i.e. {Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT}.
          # @return [Hash<Symbol, CyberReport>]
          def cyber_reports_for_holt_winters_calculation_step(ip, type, indices)
            reports = {}
            archive_api = Departments::Archive::Api.instance
            reports[:last] = archive_api
                             .cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
                               ip,
                               type,
                               'seasonal_index' => indices[:previous]
                             )
            reports[:prev_season] = archive_api
                                    .cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
                                      ip,
                                      type,
                                      'seasonal_index' => indices[:current]
                                    )
            reports[:prev_season_next_step] = archive_api
                                              .cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
                                                ip,
                                                type,
                                                'seasonal_index' => indices[:next]
                                              )
            reports[:latest] = archive_api.new_cyber_report_object_for_friendly_resource(
              ip,
              type,
              'seasonal_index' => indices[:current]
            )
            reports
          end
        end
      end
    end
  end
end
