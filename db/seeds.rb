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
  Dos::Icmp::DosIcmpInterpretation.delete_all()
end

def clearAll()
  clearCyberReports()
  FriendlyResource.delete_all()
end

def getInstanceOfFriendlyResource(name = "demo", ipAddress = IPAddr.new("79.181.31.4"))
  return FriendlyResource.new(name: name, ip_address: ipAddress.to_i)
end
# ########################################  MAIN ########################################
clearAll()
friendlyResourceAmount = 1
(1..friendlyResourceAmount).each do |friendlyResourceCount|
  friendlyResource = getInstanceOfFriendlyResource(
    "demo_#{friendlyResourceCount}",
    IPAddr.new("79.181.31.#{friendlyResourceCount}")
  )
  friendlyResource.save()
end