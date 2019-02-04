# frozen_string_literal: true

require 'singleton'
require_relative './services/validation.rb'
require_relative './services/icmp_flood.rb'

module Algorithms
  ##
  # Holds +API+ and +Services+ necessary for *Holt Winters Forecasting*.
  #
  # For now we have one type of forecasting. Types are identified by constants:
  # * [Algorithms::HolWintersForecasting::ICMP_FLOOD] - modified Holt Winters forecasting
  # for ICMP Flood attacks.
  module HoltWintersForecasting
    ICMP_FLOOD = 'HOLT_WINTERS_FORECASTING_FOR_ICMP_FLOOD'
    ##
    # +API+ for consumption by other modules.
    class Api
      include Singleton

      def set_time_unit_in_seconds(type, seconds)
        Services::IcmpFlood.instance.set_time_unit_in_seconds(seconds) if type == HoltWintersForecasting::ICMP_FLOOD
      end

      def set_alpha(weights_percentage, collections_count)
        value = 1 - Math.exp((Math.log10(1 - weights_percentage)) / collections_count)
        Services::Validation.instance.exponential_smoothing_const?(value)
        @alpha = value
      end

      def set_beta(weights_percentage, collections_count)
        value = 1 - Math.exp((Math.log10(1 - weights_percentage)) / collections_count)
        Services::Validation.instance.exponential_smoothing_const?(value)
        @beta = value
      end

      def set_gamma(weights_percentage, collections_count)
        value = 1 - Math.exp((Math.log10(1 - weights_percentage)) / collections_count)
        Services::Validation.instance.exponential_smoothing_const?(value)
        @gamma = value
      end

      def set_teta(value)
        Services::Validation.instance.teta_const?(value)
        @teta = value
      end

      def seasonal_index(type)
        case type
        when HoltWintersForecasting::ICMP_FLOOD
          return HoltWintersForecasting::Services::IcmpFlood.instance.seasonal_index
        end
      end

      def prev_seasonal_index(type, index)
        case type
        when HoltWintersForecasting::ICMP_FLOOD
          return HoltWintersForecasting::Services::IcmpFlood.instance.prev_seasonal_index(index)
        end
      end

      def next_seasonal_index(type, index)
        case type
        when HoltWintersForecasting::ICMP_FLOOD
          return HoltWintersForecasting::Services::IcmpFlood.instance.next_seasonal_index(index)
        end
      end

      # Determines aberrant behavior at the moment T.
      # @param [Integer] actual_value_t Measured value at the moment T.
      # @param [Float] confidence_band_upper_value_t Maximum expected value at the moment T.
      # @return [Boolean].
      def aberrant_behavior(actual_value_t, confidence_band_upper_value_t)
        validation = Services::Validation.instance
        validation.actual_value?(actual_value_t)
        validation.confidence_band_upper_value?(confidence_band_upper_value_t)
        return actual_value_t > confidence_band_upper_value_t if confidence_band_upper_value_t

        false # Cold start.
      end

      # Determines expected value at the moment (T+1).
      # @param [Float] baseline_t Baseline at the moment T.
      # @param [Float] linear_trend_t Linear trend at the moment T.
      # @param [Float] seasonal_trend_t_plus_one_minus_m Seasonal trend at the moment (T+1-M),
      # M beign a season duration.
      # @return [Float].
      def estimated_value(baseline_t, linear_trend_t, seasonal_trend_t_plus_one_minus_m)
        validation = Services::Validation.instance
        validation.baseline?(baseline_t)
        validation.linear_trend?(linear_trend_t)
        validation.seasonal_trend?(seasonal_trend_t_plus_one_minus_m)
        result = baseline_t + linear_trend_t
        result += seasonal_trend_t_plus_one_minus_m if seasonal_trend_t_plus_one_minus_m
        validation.estimated_value?(result)
        result
      end

      # Calculates baseline at the moment T.
      # @param [Integer] actual_value_t Measured value at the moment T.
      # @param [Float] seasonal_trend_t_minus_m Seasonal trend at the moment (T-M), M beign a season duration.
      # @param [Float] baseline_t_minus_one Baseline value at the moment (T-1).
      # @param [Float] linear_trend_t_minus_one Linear trend at the moment (T-1).
      # @return [Float].
      def baseline(actual_value_t, seasonal_trend_t_minus_m, baseline_t_minus_one, linear_trend_t_minus_one)
        validation = Services::Validation.instance
        validation.actual_value?(actual_value_t)
        validation.seasonal_trend?(seasonal_trend_t_minus_m)
        validation.baseline?(baseline_t_minus_one)
        validation.linear_trend?(linear_trend_t_minus_one)
        result = actual_value_t
        result = @alpha * (result - seasonal_trend_t_minus_m) if seasonal_trend_t_minus_m
        if baseline_t_minus_one
          result += (1 - @alpha) * (baseline_t_minus_one + linear_trend_t_minus_one) if linear_trend_t_minus_one
        end
        validation.baseline?(result)
        result
      end

      # Calucalates confidence band upper value at the moment T.
      # @param [Float] estimated_value_t Estimated value at the moment T.
      # @param [Float] weighted_avg_abs_deviation_t_minus_m Weighted Avg Abs Deviation at the moment
      # (T-M), M beign a season duration.
      # @return [Float].
      def confidence_band_upper_value(estimated_value_t, weighted_avg_abs_deviation_t_minus_m)
        validation = Services::Validation.instance
        validation.estimated_value?(estimated_value_t)
        validation.weighted_avg_abs_deviation_value?(weighted_avg_abs_deviation_t_minus_m)
        result = estimated_value_t
        result += @teta * weighted_avg_abs_deviation_t_minus_m if weighted_avg_abs_deviation_t_minus_m
        validation.confidence_band_upper_value?(result)
        result
      end

      # Calculates linear trend at the moment T.
      # @param [Float] baseline_t Baseline value at the moment T.
      # @param [Float] baseline_t_minus_one Basline value at the moment (T-1).
      # @param [Float] linear_trend_t_minus_one Linear trend value at the moment (T-1).
      # @return [Float].
      def linear_trend(baseline_t, baseline_t_minus_one, linear_trend_t_minus_one)
        validation = Services::Validation.instance
        validation.baseline?(baseline_t)
        validation.baseline?(baseline_t_minus_one)
        validation.linear_trend?(linear_trend_t_minus_one)
        result = baseline_t
        result = @beta * (result - baseline_t_minus_one) if baseline_t_minus_one
        result += (1 - @beta) * linear_trend_t_minus_one if linear_trend_t_minus_one
        validation.linear_trend?(result)
        result
      end

      # Calculates seasonal trend at the moment T.
      # @param [Integer] actual_value_t Actual value at the moment T.
      # @param [Float] basline_t Baseline value at the moment T.
      # @param [Float] seasonal_trend_t_minus_m Seasonal trend at the moment (T-M), M beign
      # a season duration.
      # @return [Float].
      def seasonal_trend(actual_value_t, baseline_t, seasonal_trend_t_minus_m)
        validation = Services::Validation.instance
        validation.actual_value?(actual_value_t)
        validation.baseline?(baseline_t)
        validation.seasonal_trend?(seasonal_trend_t_minus_m)
        result = actual_value_t
        result = @gamma * (result - baseline_t) if baseline_t && baseline_t < actual_value_t
        result += (1 - @gamma) * seasonal_trend_t_minus_m if seasonal_trend_t_minus_m
        validation.seasonal_trend?(result)
        result
      end

      # Calculates weighted average absolute deviation at the moment T.
      # @param [Float] actual_value_t Actual value at the moment T.
      # @param [Float] estimated_value_t Estimated value at the moment T.
      # @param [Float] weighted_avg_abs_deviation_t_minus_m Weighted average absolute deviation value
      # at the moment (T-M), M beign a season duration.
      # @return [Float].
      def weighted_avg_abs_deviation(actual_value_t, estimated_value_t, weighted_avg_abs_deviation_t_minus_m)
        validation = Services::Validation.instance
        validation.actual_value?(actual_value_t)
        validation.estimated_value?(estimated_value_t)
        validation.weighted_avg_abs_deviation_value?(weighted_avg_abs_deviation_t_minus_m)
        result = actual_value_t
        result = @gamma * (result - estimated_value_t).abs() if estimated_value_t
        result += (1 - @gamma) * weighted_avg_abs_deviation_t_minus_m if weighted_avg_abs_deviation_t_minus_m
        validation.weighted_avg_abs_deviation_value?(result)
        result
      end
    end
  end
end
