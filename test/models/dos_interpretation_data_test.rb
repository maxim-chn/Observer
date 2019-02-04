require 'test_helper'

class DosInterpretationDataTest < ActiveSupport::TestCase
  test "create dosInterpretationData" do
    baseline                         = 1.0
    trend                            = 2.0
    seasonalTrend                    = 3.0
    weightedAverageAbsoluteDeviation = 3.5
    aberrantBehavior                 = true
    actualValue                      = 10.0
    dosInterpretationData = DosInterpretationData.new(
      baseline: baseline,
      trend: trend,
      seasonal_trend: seasonalTrend,
      weighted_average_absolute_deviation: weightedAverageAbsoluteDeviation,
      aberrant_behavior: aberrantBehavior,
      actual_value: actualValue
    )
    assert(baseline == dosInterpretationData.baseline,
           "New dosInterpretationData has unexpected baseline")
    assert(trend == dosInterpretationData.trend,
           "New dosInterpretationData has unexpected trend")
    assert(seasonalTrend == dosInterpretationData.seasonal_trend,
           "New dosInterpretationData has unexpected seasonalTrend")
    assert(weightedAverageAbsoluteDeviation ==
      dosInterpretationData.weighted_average_absolute_deviation,
           "New dosInterpretationData has unexpected weightedAverageAbsoluteDeviation")
    assert(aberrantBehavior == dosInterpretationData.aberrant_behavior,
           "New dosInterpretationData has unexpected aberrantBehavior")
    assert(actualValue == dosInterpretationData.actual_value,
           "New dosInterpretationData has unexpected actualValue")
  end
end
