module Dos
  module Icmp
    class DosIcmpInterpretation < Dos::DosReport
      # DoS interpretation data for ICMP protocol.
      # had to remove "data" from class name, due to restrictions on class name length.
      # We have additional "DosIcmp" in class name, because Rails translates
      # class name into table name and neglects namespacing before class name.
      belongs_to       :friendly_resource, class_name: 'FriendlyResource'
      after_initialize :initDefaultValues
      def initDefaultValues()
        if self.seasonal_index
          minSeasonalIndex = DosReport::FIRST_SEASONAL_INDEX
          maxSeasonalIndex = DosReport::LAST_SEASONAL_INDEX
          if (self.seasonal_index < minSeasonalIndex || self.seasonal_index > maxSeasonalIndex)
            throw Exception.new("#{self.class.name} - #{__method__} - seasonal_index must be in range [#{minSeasonalIndex},#{maxSeasonalIndex}].")
          elsif (self.report_type.nil?())
            throw Exception.new("#{self.class.name} - #{__method__} - report_type must have a value.")
          else
            self.aberrant_behavior           = 0.0 unless self.aberrant_behavior
            self.actual_value                = 0.0 unless self.actual_value
            self.baseline                    = 0.0 unless self.baseline
            self.confidence_band_upper_value = 0.0 unless self.confidence_band_upper_value
            self.estimated_value             = 0.0 unless self.estimated_value
            self.linear_trend                = 0.0 unless self.linear_trend
            self.seasonal_trend              = 0.0 unless self.seasonal_trend
            self.weighted_avg_abs_deviation  = 0.0 unless self.weighted_avg_abs_deviation
          end
        else
          throw Exception.new("#{self.class.name} - #{__method__} - missing seasonal_index value. It is mandatory for new object.")
        end
      end
      def inspect()
        result = {}
        result[:aberrantBehavior]         = aberrant_behavior
        result[:actualValue]              = actual_value
        result[:baseline]                 = baseline
        result[:confidenceBandUpperValue] = confidence_band_upper_value
        result[:estimatedValue]           = estimated_value
        result[:trend]                    = linear_trend
        result[:seasonalIndex]            = seasonal_index
        result[:seasonalTrend]            = seasonal_trend
        result[:weightedAvgAbsDeviation]  = weighted_avg_abs_deviation
        return JSON.generate(result)
      end
    end # InterpretationData
  end # Icmp
end # Dos
