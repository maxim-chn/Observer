require 'test_helper'

class FriendlyResourceTest < ActiveSupport::TestCase
  test "friendly_resource creation" do
    name              = "demo"
    ip_address        = IPAddr.new("79.181.31.4")
    friendly_resource = FriendlyResource.new(name: "demo", ip_address: ip_address.to_i)
    assert(name == friendly_resource.name,
      "New FriendlyResource has unexpected name"
    )
    assert(ip_address == IPAddr.new(friendly_resource.ip_address, Socket::AF_INET),
      "New FriendlyResource has unexpected ip_address"
    )
  end

  test "friendly_resource with cyber_reports creation" do
    name              = "demo"
    ip_address        = IPAddr.new("79.181.31.4")
    new_friendly_resource = FriendlyResource.new(name: "demo", ip_address: ip_address.to_i)
    baseline                            = 1.0
    trend                               = 2.0
    seasonal_trend                      = 3.0
    weighted_average_absolute_deviation = 3.5
    aberrant_behavior                   = true
    actual_value                        = 10.0
    new_friendly_resource.dos_interpretation_data << DosInterpretationData.new(
      baseline:                             baseline,
      trend:                                trend,
      seasonal_trend:                       seasonal_trend,
      weighted_average_absolute_deviation:  weighted_average_absolute_deviation,
      aberrant_behavior:                    aberrant_behavior,
      actual_value:                         actual_value
    )
    new_friendly_resource.save()
    friendly_resource = FriendlyResource.find_by(name: name)
    dos_interpretation_data = friendly_resource.cyber_reports.first()
    assert(name == friendly_resource.name,
      "New FriendlyResource has unexpected name"
    )
    assert(ip_address == IPAddr.new(friendly_resource.ip_address, Socket::AF_INET),
      "New FriendlyResource has unexpected ip_address"
    )
    assert(baseline == dos_interpretation_data.baseline,
      "New dos_interpretation_data has unexpected baseline"  
    )
    assert(trend == dos_interpretation_data.trend,
      "New dos_interpretation_data has unexpected trend"  
    )
    assert(seasonal_trend == dos_interpretation_data.seasonal_trend,
      "New dos_interpretation_data has unexpected seasonal_trend"  
    )
    assert(weighted_average_absolute_deviation ==
      dos_interpretation_data.weighted_average_absolute_deviation,
      "New dos_interpretation_data has unexpected weighted_average_absolute_deviation"  
    )
    assert(aberrant_behavior == dos_interpretation_data.aberrant_behavior,
      "New dos_interpretation_data has unexpected aberrant_behavior"  
    )
    assert(actual_value == dos_interpretation_data.actual_value,
      "New dos_interpretation_data has unexpected actual_value"  
    )
  end
end
