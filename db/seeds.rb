require 'ipaddr'

def clear_cyber_reports
  Dos::IcmpFloodReport.delete_all
end

def clear_all
  clear_cyber_reports
  FriendlyResource.delete_all
end

def new_friendly_resource(name = "demo", ipAddress = IPAddr.new("79.181.31.4"))
  return FriendlyResource.new(name: name, ip_address: ipAddress.to_i)
end

clear_all
friendly_resources_amount = 1
(1..friendly_resources_amount).each do |n|
  friendlyResource = new_friendly_resource(
    "demo_#{n}",
    IPAddr.new("79.181.31.#{n}")
  )
  friendlyResource.save
end
