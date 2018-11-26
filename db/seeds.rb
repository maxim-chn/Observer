# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'ipaddr'
# ######################################## HELPERS ########################################
def clearCyberReports()
  DosInterpretationData.delete_all()
end

def clearAll()
  clearCyberReports()
  FriendlyResource.delete_all()
end

def getInstanceOfFriendlyResource(name = "demo", ipAddress = IPAddr.new("79.181.31.4"))
  return FriendlyResource.new(name: name, ip_address: ipAddress.to_i)
end

def getInstanceOfDosInterpretationData(
  baseline = 0.0, trend = 0.0, seasonalTrend = 0.0,
  weightedAverageAbsoluteDeviation = 0.0, aberrantBehavior = false, actualValue = 0.0
  )
  return DosInterpretationData.new(
    baseline:                             baseline,
    trend:                                trend,
    seasonal_trend:                       seasonalTrend,
    weighted_average_absolute_deviation:  weightedAverageAbsoluteDeviation,
    aberrant_behavior:                    aberrantBehavior,
    actual_value:                         actualValue
  )
end
# ########################################  MAIN ########################################
clearAll()
friendlyResourceAmount = 2
dosInterpretationDataAmount = 2
(1..friendlyResourceAmount).each do |friendlyResourceCount|
  friendlyResource = getInstanceOfFriendlyResource(
    "demo_#{friendlyResourceCount}",
    IPAddr.new("79.181.31.#{friendlyResourceCount}")
  )
  (1..dosInterpretationDataAmount).each do |dosInterpretationCount|
    friendlyResource.dos_interpretation_data << getInstanceOfDosInterpretationData()
  end
  friendlyResource.save()
end