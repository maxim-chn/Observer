require 'test_helper'

class FriendlyResourceTest < ActiveSupport::TestCase
  test "friendlyResource creation" do
    name = "demo"
    ipAddress        = IPAddr.new("79.181.31.4")
    friendlyResource = FriendlyResource.new(name: "demo", ip_address: ipAddress.to_i)
    assert(name == friendlyResource.name,
           "New FriendlyResource has unexpected name")
    assert(ipAddress == IPAddr.new(friendlyResource.ip_address, Socket::AF_INET),
           "New FriendlyResource has unexpected ipAddress")
  end

  test "friendlyResource with cyber_reports creation" do
    name = "demo"
    ipAddress = IPAddr.new("79.181.31.4")
    newFriendlyResource = FriendlyResource.new(name: "demo", ip_address: ipAddress.to_i)
    baseline                         = 1.0
    trend                            = 2.0
    seasonalTrend                    = 3.0
    weightedAverageAbsoluteDeviation = 3.5
    aberrantBehavior                 = true
    actualValue                      = 10.0
    newFriendlyResource.dos_interpretation_data << DosInterpretationData.new(
      baseline: baseline,
      trend: trend,
      seasonal_trend: seasonalTrend,
      weighted_average_absolute_deviation: weightedAverageAbsoluteDeviation,
      aberrant_behavior: aberrantBehavior,
      actual_value: actualValue
    )
    newFriendlyResource.save()
    friendlyResource = FriendlyResource.find_by(name: name)
    dosInterpretationData = friendlyResource.latestCyberReports.first()
    assert(name == friendlyResource.name,
           "New FriendlyResource has unexpected name")
    assert(ipAddress == IPAddr.new(friendlyResource.ip_address, Socket::AF_INET),
           "New FriendlyResource has unexpected ipAddress")
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
