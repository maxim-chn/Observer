# frozen_string_literal: true

module Workers
  module Demo
    module Analysis
      module Dos
        module Icmp
          ##
          # A Sidekiq worker that produces [IcmpFloodReport].
          class CyberReportProducer < Workers::Demo::Analysis::Dos::HoltWintersForecastingWorker
            include Sidekiq::Worker
            sidekiq_options retry: false

            # Asynchronously creates [CyberReport] object for moment T and
            # consumes [ArchiveApi] to persist it.
            # +ip+ - friendly resource ip.
            # +type+ - [CyberReport] type.
            # +intelligence_data+ - [Hash] with intelligence data.
            def perform(ip, type, intelligence_data)
              logger.info("#{self.class.name} - #{__method__} - IP : #{ip}.\n \
                intelligence_data : #{intelligence_data}.")
              begin
                indices = seasonal_indices_for_holt_winters_calculation_step
                logger.debug("#{self.class.name} - #{__method__} - seasonal indices : #{indices}")
                reports = cyber_reports_for_holt_winters_calculation_step(
                  ip,
                  type,
                  indices
                )
                logger.debug("#{self.class.name} - #{__method__} - cyber reports : \n \
                  #{reports}")
                forecasting_step(
                  cyber_report_at_prev_season,
                  cyber_report_at_prev_season_for_next_step,
                  last_cyber_report,
                  latest_cyber_report,
                  intelligence_data[:incoming_req_count]
                )
                archive_api.persist_cyber_report(latest_cyber_report)
                logger.debug("#{self.class.name} - #{__method__} - persisted \
                  #{latest_cyber_report.inspect}.")
              rescue StandardError => e
                logger.error("#{self.class.name} - #{__method__} - failed - reason : #{e.inspect}")
              end
            end

            private

            # @return [Hash] of seasonal indices.
            def seasonal_indices_for_holt_winters_calculation_step
              indices = {}
              hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
              indices[:current] = hw_forecasting_api.seasonal_index
              indices[:previous] = hw_forecasting_api.previous_seasonal_index(indices[:current])
              indices[:next] = hw_forecasting_api.next_seasonal_index(indices[:current])
              indices
            end

            # +ip+ - [FriendlyResource] IP.
            # +type+ - type of [CyberReport]
            # +indices+ - [Hash] of seasonal indices
            # * +indices[:last]+ - seasonal index at moment (T-1).
            # * +indices[:prev_season] - seasonal index at moment (T-M),
            # M duration of a season.
            # * +indices[:prev_season_next_step] - seasonal index at moment (T+1-M).
            # * +indices[:latest] - seasonal index at moment T.
            # @return [Hash] with [CyberReport]s
            def cyber_reports_for_holt_winters_calculation_step(ip, type, indices)
              reports = {}
              archive_api = Departments::Demo::Archive::Api.instance
              reports[:last] = archive_api
                               .get_cyber_report_by_friendly_resource_ip_and_type_and_custom_attributes(
                                 ip,
                                 type,
                                 seasonal_index: indices[:previous]
                               )
              reports[:prev_season] = archive_api
                                      .get_cyber_report_by_friendly_resource_ip_and_type_and_custom_attributes(
                                        ip,
                                        type,
                                        seasonal_index: indices[:current]
                                      )
              reports[:prev_season_next_step] = archive_api
                                                .get_cyber_report_by_friendly_resource_ip_and_type_and_custom_attributes(
                                                  ip,
                                                  type,
                                                  seasonal_index: indices[:next]
                                                )
              reports[:latest] = archive_api.get_new_cyber_report_object(
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
end
