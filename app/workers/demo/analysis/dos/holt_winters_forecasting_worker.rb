# frozen_string_literal: true

module Workers
  module Demo
    module Analysis
      module Dos
        ##
        # An abstract class that holds necessary methods for any worker performing
        # HoltWintersFrecasting analysis.
        class HoltWintersForecastingWorker < Workers::Demo::WorkerWithRedis
          private

          # Performs calculations for a single step in
          # Holt Winters Forecasting Algorithm.
          # +actual_value+ - measured value at moment T.
          # +last_cyber_report+ - [CyberReport] at moment (T-1).
          # +latest_cyber_report+ - [CyberReport] at moment T.
          # +cyber_report_at_prev_season+ - [CyberReport] at moment (T-M),
          # M duration of a season.
          # +cyber_report_at_prev_season_for_next_step+ - [CyberReport] at moment (T+1-M).
          def forecasting_step(
            cyber_report_at_prev_season,
            cyber_report_at_prev_season_for_next_step,
            last_cyber_report,
            latest_cyber_report,
            actual_value
          )
            moment_a = {} # Moment (T-M), M duration of a single season.
            moment_b = {} # Moment (T+1-M), M duration of a single season.
            moment_c = {} # Moment (T-1).
            moment_d = { actual_value: actual_value } # Moment T.
            data_at_moment_t_minus_m(moment_a, cyber_report_at_prev_season)
            logger.debug("#{self.class.name} - #{__method__} - Moment (T-M) : #{moment_a}.")
            data_at_moment_t_plus_one_minus_m(moment_b, cyber_report_at_prev_season_for_next_step)
            logger.debug("#{self.class.name} - #{__method__} - Moment (T+1-M) : #{moment_b}.")
            data_at_moment_t_minus_one(moment_c, last_cyber_report)
            logger.debug("#{self.class.name} - #{__method__} - Moment (T-1) : #{moment_c}.")
            aberrant_behavior_at_moment_t(moment_c, moment_d)
            baseline_at_moment_t(moment_a, moment_c, moment_d)
            perform_calculations_for_moment_t(moment_a, moment_b, moment_c, moment_d)
            linear_trend_at_moment_t(moment_c, moment_d)
            seasonal_trend_at_moment_t(moment_a, moment_d)
            confidence_band_upper_value_at_moment_t(moment_a, moment_c, moment_d)
            weighted_avg_abs_deviation_for_moment_t(moment_a, moment_c, moment_d)
            estimated_value_for_moment_t(moment_b, moment_d)
            logger.debug("#{self.class.name} - #{__method__} - Moment T : #{moment_d}.")
            update_cyber_report_with_calculations(latest_cyber_report, moment_d)
            logger.debug("#{self.class.name} - #{__method__} - CyberReport at moment T \
              has been updated.")
          end

          # Retrieves data from moment (T-1),
          # necessary for calculation of moment T.
          # +moment+ - [Hash] to hold data from moment (T-1).
          # +cyber_report+ - [CyberReport] for moment (T-1).
          def data_at_moment_t_minus_one(moment, cyber_report)
            moment[:baseline] = baseline(cyber_report)
            moment[:linear_trend] = linear_trend(cyber_report)
            moment[:estimated_value] = estimated_value(cyber_report)
            moment[:confidence_band_upper_value] = confidence_band_upper_value(cyber_report)
          end

          # Retrieves data from moment (T-M), M duration of a season,
          # necessary for calculation of moment T.
          # +moment+ - [Hash] to hold data from moment (T-M).
          # +cyber_report+ - [CyberReport] for moment (T-1).
          def data_at_moment_t_minus_m(moment, cyber_report)
            moment[:seasonal_trend] = seasonal_trend(cyber_report)
            moment[:weight_avg_abs_deviation] = weighted_avg_abs_deviation(cyber_report)
          end

          # Retrieves data from moment (T+1-M), M duration of a season,
          # necessary for calculation of moment T.
          # +moment+ - [Hash] to hold data from moment (T+1-M).
          # +cyber_report+ - [CyberReport] for moment (T+1-M).
          def data_at_moment_t_plus_one_minus_m(moment, cyber_report)
            moment[:seasonal_trend] = seasonal_trend(cyber_report)
          end

          # Calculates data for moment T. The data represents [CyberReport].
          # +moment_a+ - [Hash] with data from moment (T-M), M duration of a season.
          # +moment_b+ - [Hash] with data from moment (T+1-M).
          # +moment_c+ - [Hash] with data from moment (T-1).
          # +moment_d+ - [Hash] with data from moment T.
          def aberrant_behavior_at_moment_t(moment_c, moment_d)
            hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
            moment_d[:aberrant_behavior] = hw_forecasting_api.is_aberrant_behavior(
              moment_d[:actual_value],
              moment_c[:confidence_band_upper_value]
            )
          end

          def baseline_at_moment_t(moment_a, moment_c, moment_d)
            hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
            moment_d[:baseline] = hw_forecasting_api.baseline(
              moment_d[:actual_value],
              moment_a[:seasonal_trend],
              moment_c[:baseline],
              moment_c[:linear_trend]
            )
          end

          def linear_trend_at_moment_t(moment_c, moment_d)
            hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
            moment_d[:linear_trend] = hw_forecasting_api.linear_trend(
              moment_d[:baseline],
              moment_c[:baseline],
              moment_c[:linear_trend]
            )
          end

          def seasonal_trend_at_moment_t(moment_a, moment_d)
            hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
            moment_d[:seasonal_trend] = hw_forecasting_api.seasonal_trend(
              moment_d[:actual_value],
              moment_d[:baseline],
              moment_a[:seasonal_trend]
            )
          end

          def confidence_band_upper_value_at_moment_t(moment_a, moment_c, moment_d)
            hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
            moment_d[:confidence_band_upper_value] = hw_forecasting_api.confidence_band_upper_value(
              moment_c[:estimated_value],
              moment_a[:weighted_avg_abs_deviation]
            )
          end

          def weighted_avg_abs_deviation_for_moment_t(moment_a, moment_c, moment_d)
            hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
            moment_d[:weighted_avg_abs_deviation] = hw_forecasting_api.weighted_avg_abs_deviation(
              moment_d[:actual_value],
              moment_c[:estimated_value],
              moment_a[:weighted_avg_abs_deviation]
            )
          end

          def estimated_value_for_moment_t(moment_b, moment_d)
            moment_d[:estimated_value] = hw_forecasting_api.estimated_value(
              moment_d[:baseline],
              moment_d[:linear_trend],
              moment_b[:seasonal_trend]
            )
          end

          # Update [CyberReport] for moment T with necessary data.
          # +report+ - [CyberReport] at moment T.
          # +moment+ - [Hash] with data for moment T.
          def update_cyber_report_with_calculations(report, moment)
            report.actual_value = moment[:actual_value]
            report.baseline = moment[:baseline]
            report.confidence_band_upper_value = moment[:confidence_band_upper_value]
            report.estimated_value = moment[:estimated_value]
            report.aberrant_behavior = moment[:aberrant_behavior]
            report.linear_trend = moment[:linear_trend]
            report.seasonal_trend = moment[:seasonal_trend]
            report.weighted_avg_abs_deviation = moment[:weighted_avg_abs_deviation]
          end

          def baseline(cyber_report)
            return cyber_report.baseline if cyber_report&.baseline

            0.0
          end

          def linear_trend(cyber_report)
            return cyber_report.linear_trend if cyber_report&.linear_trend

            0.0
          end

          def estimated_value(cyber_report)
            return cyber_report.estimated_value if cyber_report&.estimated_value

            0.0
          end

          def confidence_band_upper_value(cyber_report)
            return cyber_report.confidence_band_upper_value if cyber_report
          end

          def seasonal_trend(cyber_report)
            return cyber_report.seasonal_trend if cyber_report&.seasonal_trend

            0.0
          end

          def weighted_avg_abs_deviation(cyber_report)
            if cyber_report
              return cyber_report.weighted_avg_abs_deviation if cyber_report.weighted_avg_abs_deviation
            end
            0.0
          end
        end
      end
    end
  end
end
