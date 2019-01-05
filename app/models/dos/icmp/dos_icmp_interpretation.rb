module Dos
  module Icmp
    class DosIcmpInterpretation < Dos::DosReport
      # DoS interpretation data for ICMP protocol.
      # had to remove "data" from class name, due to restrictions on class name length.
      # We have additional "DosIcmp" in class name, because Rails translates
      # class name into table name and neglects namespacing before class name :(.
      belongs_to       :friendly_resource,    class_name: 'FriendlyResource'
      after_initialize :initDefaultValues
      def initDefaultValues()
        if self.seasonal_index
          minSeasonalIndex = DosReport::FIRST_SEASONAL_INDEX
          maxSeasonalIndex = DosReport::SEASON_DURATION_IN_SECONDS / DosReport::INTERVAL_BETWEEN_COLLECTIONS_IN_SECONDS - 1
          if(self.seasonal_index >= minSeasonalIndex && self.seasonal_index <= maxSeasonalIndex)
            self.baseline                   = 0.0 unless self.baseline
            self.linear_trend               = 0.0 unless self.linear_trend
            self.seasonal_trend             = 0.0 unless self.seasonal_trend
            self.weighted_avg_abs_deviation = 0.0 unless self.weighted_avg_abs_deviation
            self.aberrant_behavior          = 0.0 unless self.aberrant_behavior
            self.actual_value               = 0.0 unless self.actual_value
          else
            throw Exception.new("seasonal_index must be in range [#{minSeasonalIndex},#{maxSeasonalIndex}].")
          end
        else
          throw Exception.new("Missing mandatory seasonal_index value for new dos icmp interpretation data.")
        end
      end
      def inspect()
        result = {}
        result['baseline']                = baseline
        result['trend']                   = linear_trend
        result['seasonalIndex']           = seasonal_index
        result['seasonalTrend']           = seasonal_trend
        result['weightedAvgAbsDeviation'] = weighted_avg_abs_deviation
        result['aberrantBehavior']        = aberrant_behavior
        result['actualValue']             = actual_value
        return JSON.generate(result)
      end
    end # InterpretationData
  end # Icmp
end # Dos
