# frozen_string_literal: true

module Workers
  module Analysis
    module Dos
      module Icmp
        ##
        # Produces Dos::IcmpFloodReport.
        class CyberReportProducer < Workers::Analysis::Dos::HoltWintersForecastingWorker
          include Sidekiq::Worker
          sidekiq_options retry: false

          # Asynchronously creates CyberReport object for the moment T.
          # Consumes Departments::Archive::Api to persist it.
          # [ip] Integer.
          #      FriendlyResource ip.
          # [type] Enum.
          #        CyberReport type. Necessary during Departments::Archive::Api consumption.
          # [intelligence_data] Hash.
          # [return] Void.
          def perform(ip, type, intelligence_data)
            logger.info("#{self.class.name} - #{__method__} - IP : #{ip}, type: #{type}, \
              intelligence_data : #{intelligence_data}.")
            begin
              indices = seasonal_indices_for_holt_winters_calculation_step
              logger.debug("#{self.class.name} - #{__method__} - seasonal indices : #{indices}.")
              reports = cyber_reports_for_holt_winters_calculation_step(
                ip,
                type,
                indices
              )
              logger.debug("#{self.class.name} - #{__method__} - cyber reports : #{reports}.")
              forecasting_step(
                reports[:prev_season],
                reports[:prev_season_next_step],
                reports[:last],
                reports[:latest],
                intelligence_data['incoming_req_count']
              )
              Departments::Archive::Api.instance.persist_cyber_report(reports[:latest])
              logger.debug("#{self.class.name} - #{__method__} - persisted #{reports[:latest].inspect}.")
            rescue StandardError => e
              logger.error("#{self.class.name} - #{__method__} - failed - reason : #{e.message}.")
            end
          end

          private

          # Retrieves seasonal indices of CyberReport objects,
          # necessary for Holt Winters calculation step.
          # [return] Hash.
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

          # Retrieves [CyberReport] objects by their seasonal indices.
          # [ip] Integer.
          #      FriendlyResource ip.
          # [type] Enum.
          #        CyberReport type.
          # [indices] Hash.
          #           Seasonal indices.
          #             * :last - seasonal index at the moment (T-1).
          #             * :prev_season - seasonal index at the moment (T-M), M beign a season duration.
          #             * :prev_season_next_step - seasonal index at the moment (T+1-M).
          #             * :latest - seasonal index at the moment T.
          # [return] [Hash].
          def cyber_reports_for_holt_winters_calculation_step(ip, type, indices)
            reports = {}
            archive_api = Departments::Archive::Api.instance
            reports[:last] = archive_api
                             .cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
                               ip,
                               type,
                               seasonal_index: indices[:previous]
                             )
            reports[:prev_season] = archive_api
                                    .cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
                                      ip,
                                      type,
                                      seasonal_index: indices[:current]
                                    )
            reports[:prev_season_next_step] = archive_api
                                              .cyber_report_by_friendly_resource_ip_and_type_and_custom_attr(
                                                ip,
                                                type,
                                                seasonal_index: indices[:next]
                                              )
            reports[:latest] = archive_api.new_cyber_report_object_for_friendly_resource(
              ip,
              type,
              seasonal_index: indices[:current]
            )
            reports
          end
        end
      end
    end
  end
end
