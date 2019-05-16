# frozen_string_literal: true

module Workers
  ##
  # Scopes the workers that are invoked from {Departments::Analysis} module.
  module Analysis
    ##
    # Scopes the workers that interpret the data related to the {https://en.wikipedia.org/wiki/DOS DOS} analysis.
    module Dos
      ##
      # An abstract class that holds the necessary methods for any worker performing the
      # {https://ieeexplore.ieee.org/document/4542524 Modified Holt Winters Forecasting} analysis.
      class HoltWintersForecastingWorker < Workers::WorkerWithRedis
        # Performs the calculations for a single step in the
        # {https://ieeexplore.ieee.org/document/4542524 Modified Holt Winters Forecasting}.
        # M is a duration of a single season.
        # @param [CyberReport] cyber_report_t_minus_m {CyberReport} at the moment (T-M).
        # @param [CyberReport] cyber_report_t_plus_one_minus_m {CyberReport} at the moment (T+1-M).
        # @param [CyberReport] cyber_report_t_minus_one {CyberReport} at the moment (T-1).
        # @param [CyberReport] cyber_report_t {CyberReport} at the moment T.
        # @param [Integer] actual_value Measured value, during past interval, i.e. amount of incoming requests.
        # @return [Void]
        def forecasting_step(
          cyber_report_t_minus_m,
          cyber_report_t_plus_one_minus_m,
          cyber_report_t_minus_one,
          cyber_report_t,
          actual_value,
          log: false
        )
          moment_a = {} # Moment (T-M).
          moment_b = {} # Moment (T+1-M).
          moment_c = {} # Moment (T-1).
          moment_d = { actual_value: actual_value } # Moment T.
          data_at_moment_t_minus_m(moment_a, cyber_report_t_minus_m)
          logger.info("#{self.class.name} - #{__method__} - Moment (T-M) : #{moment_a}.") if log
          data_at_moment_t_plus_one_minus_m(moment_b, cyber_report_t_plus_one_minus_m)
          logger.info("#{self.class.name} - #{__method__} - Moment (T+1-M) : #{moment_b}.") if log
          data_at_moment_t_minus_one(moment_c, cyber_report_t_minus_one)
          logger.info("#{self.class.name} - #{__method__} - Moment (T-1) : #{moment_c}.") if log
          logger.info("#{self.class.name} - #{__method__} - Moment T, before calculations : #{moment_d}.") if log
          aberrant_behavior_at_moment_t(moment_c, moment_d)
          baseline_at_moment_t(moment_a, moment_c, moment_d)
          linear_trend_at_moment_t(moment_c, moment_d)
          seasonal_trend_at_moment_t(moment_a, moment_d)
          estimated_value_for_moment_t(moment_b, moment_d)
          weighted_avg_abs_deviation_for_moment_t(moment_a, moment_c, moment_d)
          confidence_band_upper_value_at_moment_t(moment_a, moment_c, moment_d)
          update_cyber_report_with_calculations(cyber_report_t, moment_d)
        end

        # Populates relevant data from {CyberReport} to Hash object.
        # @param [Hash] moment Will hold data for the moment (T-1).
        # @param [CyberReport] cyber_report Cyber report with data for the moment (T-1).
        # @return [Void]
        def data_at_moment_t_minus_one(moment, cyber_report)
          moment[:baseline] = baseline(cyber_report)
          moment[:linear_trend] = linear_trend(cyber_report)
          moment[:estimated_value] = estimated_value(cyber_report)
          moment[:confidence_band_upper_value] = confidence_band_upper_value(cyber_report)
        end

        # Populates relevant data from {CyberReport} to Hash object.
        # @param [Hash] moment Will hold data for the moment (T-M).
        # M being a duration of a season.
        # @param [CyberReport] cyber_report Cyber report with data for the moment (T-M).
        # @return [Void]
        def data_at_moment_t_minus_m(moment, cyber_report)
          moment[:seasonal_trend] = seasonal_trend(cyber_report)
          moment[:weight_avg_abs_deviation] = weighted_avg_abs_deviation(cyber_report)
        end

        # Populates relevant data from {CyberReport} to Hash object.
        # @param [Hash] moment Will hold data for the moment (T-M+1).
        # M being a duration of a season.
        # @param [CyberReport] cyber_report Cyber report with data for the moment (T-M+1).
        # @return [Void]
        def data_at_moment_t_plus_one_minus_m(moment, cyber_report)
          moment[:seasonal_trend] = seasonal_trend(cyber_report)
        end

        # Updates aberrant_behavior for the moment T.
        # @param [Hash] moment_c Holds data for the moment (T-1).
        # @param [Hash] moment_d Holds data for the moment T.
        # @return [Void]
        def aberrant_behavior_at_moment_t(moment_c, moment_d)
          result = Algorithms::HoltWintersForecasting::Api.instance.aberrant_behavior(
            moment_d[:actual_value],
            moment_c[:confidence_band_upper_value]
          )
          moment_d[:aberrant_behavior] = result
        end

        # Updates baseline for the moment T.
        # @param [Hash] moment_a Holds data for the moment (T-M).
        # M beign a duration of a season.
        # @param [Hash] moment_c Holds data for the moment (T-1).
        # @param [Hash] moment_d Holds data for the moment T.
        # @return [Void]
        def baseline_at_moment_t(moment_a, moment_c, moment_d)
          moment_d[:baseline] = Algorithms::HoltWintersForecasting::Api.instance.baseline(
            moment_d[:actual_value],
            moment_a[:seasonal_trend],
            moment_c[:baseline],
            moment_c[:linear_trend]
          )
        end

        # Updates aberrant_behavior for the moment T.
        # @param [Hash] moment_c Holds data for the moment (T-1).
        # @param [Hash] moment_d Holds data for the moment T.
        # @return [Void]
        def linear_trend_at_moment_t(moment_c, moment_d)
          moment_d[:linear_trend] = Algorithms::HoltWintersForecasting::Api.instance.linear_trend(
            moment_d[:baseline],
            moment_c[:baseline],
            moment_c[:linear_trend]
          )
        end

        # Updates seasonal_trend for the moment T.
        # @param [Hash] moment_a Holds data for the moment (T-M).
        # M beign a duration of a season.
        # @param [Hash] moment_d Holds data for the moment T.
        # @return [Void]
        def seasonal_trend_at_moment_t(moment_a, moment_d)
          moment_d[:seasonal_trend] = Algorithms::HoltWintersForecasting::Api.instance.seasonal_trend(
            moment_d[:actual_value],
            moment_d[:baseline],
            moment_a[:seasonal_trend]
          )
        end

        # Updates confidence_band for the moment T.
        # @param [Hash] moment_a Holds data for the moment (T-M).
        # M beign a duration of a season.
        # @param [Hash] moment_c Holds data for the moment (T-1).
        # @param [Hash] moment_d Holds data for the moment T.
        # @return [Void]
        def confidence_band_upper_value_at_moment_t(moment_a, moment_c, moment_d)
          return moment_d[:confidence_band_upper_value] = moment_d[:estimated_value] unless moment_c[:estimated_value]

          hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
          moment_d[:confidence_band_upper_value] = hw_forecasting_api.confidence_band_upper_value(
            moment_c[:estimated_value],
            moment_a[:weighted_avg_abs_deviation]
          )
        end

        # Updates weighted_avg_abs_deviation for the moment T.
        # @param [Hash] moment_a Holds data for the moment (T-M).
        # M beign a duration of a season.
        # @param [Hash] moment_c Holds data for the moment (T-1).
        # @param [Hash] moment_d Holds data for the moment T.
        # @return [Void]
        def weighted_avg_abs_deviation_for_moment_t(moment_a, moment_c, moment_d)
          hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
          moment_d[:weighted_avg_abs_deviation] = hw_forecasting_api.weighted_avg_abs_deviation(
            moment_d[:actual_value],
            moment_c[:estimated_value],
            moment_a[:weighted_avg_abs_deviation]
          )
        end

        # Updates estimated_value for the moment T.
        # @param [Hash] moment_b Holds data for the moment (T-M+1).
        # M beign a duration of a season.
        # @param [Hash] moment_d Holds data for the moment T.
        # @return [Void]
        def estimated_value_for_moment_t(moment_b, moment_d)
          moment_d[:estimated_value] = Algorithms::HoltWintersForecasting::Api.instance.estimated_value(
            moment_d[:baseline],
            moment_d[:linear_trend],
            moment_b[:seasonal_trend]
          )
        end

        # Updates [CyberReport] with relevant data, before its persistance.
        # @param [CyberReport] report Instance of {CyberReport}
        # @param [Hash] moment Holds data for the moment (T).
        # @return [Void]
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

        # @return [Float]
        def baseline(cyber_report)
          return cyber_report.baseline if cyber_report

          nil
        end

        # @return [Float]
        def linear_trend(cyber_report)
          return cyber_report.linear_trend if cyber_report

          nil
        end

        # @return [Float]
        def estimated_value(cyber_report)
          return cyber_report.estimated_value if cyber_report

          nil
        end

        # @return [Float]
        def confidence_band_upper_value(cyber_report)
          return cyber_report.confidence_band_upper_value if cyber_report

          nil
        end

        # @return [Float]
        def seasonal_trend(cyber_report)
          return cyber_report.seasonal_trend if cyber_report

          nil
        end

        # @return [Float]
        def weighted_avg_abs_deviation(cyber_report)
          return cyber_report.weighted_avg_abs_deviation if cyber_report

          nil
        end
      end
    end
  end
end
