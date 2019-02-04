# frozen_string_literal: true

require 'singleton'

module Algorithms
  module HoltWintersForecasting
    module Services
      class Validation
        include Singleton

        def set_defaults
          @min_exp_value = 0
          @max_exp_value = 1
          @teta_min = 2
          @teta_max = 3
        end

        def exponential_smoothing_const?(const)
          return if (@min_exp_value..@max_exp_value).include?(const)

          throw StandardError.new("#{self.class.name} - #{__method__} - #{const} must belong\
            to [#{@min_exp_value},#{@max_exp_value}].")
        end

        def teta_const?(const)
          return if (@teta_min..@teta_max).include?(const)

          throw StandardError.new("#{self.class.name} - #{__method__} - #{const} must belong\
            to [#{@teta_min},#{@teta_max}].")
        end

        def actual_value?(value)
          return if value.class == Integer && value >= 0

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            a non negative #{Integer.name}.")
        end

        def confidence_band_upper_value?(value)
          nil_or_non_negative_float(value)
        end

        def baseline?(value)
          nil_or_non_negative_float(value)
        end

        def linear_trend?(value)
          nil_or_non_negative_float(value)
        end

        def seasonal_trend?(value)
          nil_or_non_negative_float(value)
        end

        def estimated_value?(value)
          nil_or_non_negative_float(value)
        end

        def weighted_avg_abs_deviation_value?(value)
          nil_or_non_negative_float(value)
        end

        private

        def non_negative_float?(value)
          return if value.class == Float || value.class == Integer && value > 0

          throw StandardError.new("#{self.class.name} - #{__method__} - #{value} must be\
            a non negative #{Float.name} or #{Integer.name}.")
        end

        def nil_or_non_negative_float(value)
          return if value.class == NilClass

          begin
            non_negative_float?(value)
          rescue StandardError => e
            throw StandardError.new("#{e.message} Or #{NilClass.name}.")
          end
        end
      end
    end
  end
end
