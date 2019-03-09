# frozen_string_literal: true

require 'singleton'
require 'time'
require_relative './validation'

module Algorithms
  module HoltWintersForecasting
    ##
    # Any long / supporting implementations that are used in {Algorithms::HoltWintersForecasting::Api}
    # are under this module.
    module Services
      ##
      # Methods related directly to analysing ICMP flood attack with
      # {https://ieeexplore.ieee.org/document/4542524 Modified Holt Winters Forecasting} analysis.
      class IcmpFlood
        include Singleton

        # @return [Integer]
        def min_seasonal_index
          validate_seasonal_index(@min_seasonal_index)
          @min_seasonal_index
        end

        # @return [Integer]
        def max_seasonal_index
          validate_seasonal_index(@max_seasonal_index)
          @max_seasonal_index
        end

        # Because we use a Singleton, there is no init method where we pass default values.
        # This method is a workaround.
        # @return [Void]
        def defaults
          @hours_in_a_day = 24
          @mins_in_an_hour = 60
          @secs_in_a_min = 60
          @min_seasonal_index = 0
        end

        # Set duration of a single time unit of the forecasting algorithm in seconds.
        # @return [Void]
        def time_unit_in_seconds(seconds)
          Services::Validation.instance.seconds?(seconds)
          @time_unit = seconds
          update_max_seasonal_index(seconds)
        end

        # Get a HH:mm:ss representation of a time unit of the forecasting algorithm.
        # @return [String]
        def seasonal_index_reverse(index)
          time_in_seconds = index * @time_unit
          secs = time_in_seconds % @secs_in_a_min
          mins = ((time_in_seconds - secs) % (@mins_in_an_hour * @secs_in_a_min)) / @secs_in_a_min
          hour = (time_in_seconds - secs) / (@mins_in_an_hour * @secs_in_a_min)
          "#{hour}:#{mins}:#{secs}"
        end

        # @return [Integer]
        def seasonal_index
          hour = DateTime.now.strftime('%H').to_i
          mins = DateTime.now.strftime('%M').to_i
          secs = DateTime.now.strftime('%S').to_i
          index = (hour * @mins_in_an_hour * @secs_in_a_min + mins * @secs_in_a_min + secs) / @time_unit
          validate_seasonal_index(index)
          index
        end

        # @return [Integer]
        def prev_seasonal_index(index)
          validate_seasonal_index(index)
          return index - 1 if index > @min_seasonal_index

          @max_seasonal_index
        end

        # @return [Integer]
        def next_seasonal_index(index)
          validate_seasonal_index(index)
          return index + 1 if index < @max_seasonal_index

          @min_seasonal_index
        end

        private

        def update_max_seasonal_index(collection_interval_in_sec)
          season_duration_in_sec = @hours_in_a_day * @mins_in_an_hour * @secs_in_a_min
          @max_seasonal_index = season_duration_in_sec / collection_interval_in_sec - 1
        end

        def validate_seasonal_index(index)
          return if (@min_seasonal_index..@max_seasonal_index).cover?(index)

          throw StandardError.new("#{self.class.name} - #{__method__} - #{index} must belong\
            to [#{@min_seasonal_index},#{@max_seasonal_index}].")
        end
      end
    end
  end
end
