require 'singleton'

module Algorithms
  module HoltWintersForecasting
    module Services
      class IcmpFlood
        include Singleton
        
        def intialize
          @mins_in_an_hour = 60
          @secs_in_a_min = 60
        end

        def set_time_unit_in_seconds(seconds)
          @time_unit = seconds
        end

        def seasonal_index
          hour = DateTime.now.strftime('%H').to_i
          mins = DateTime.now.strftime('%M').to_i
          secs = DateTime.now.strftime('%S').to_i
          ((hour * @mins_in_an_hour) + (mins * @secs_in_a_min) + (secs)) / @time_unit
        end
      end
    end
  end
end
