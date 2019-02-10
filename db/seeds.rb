# frozen_string_literal: true

require 'ipaddr'

def clear_cyber_reports
  Dos::IcmpFloodReport.delete_all
end

def clear_all
  clear_cyber_reports
  FriendlyResource.delete_all
end

def new_friendly_resource(name = 'demo', ip_address = IPAddr.new('79.181.31.4'))
  FriendlyResource.new(name: name, ip_address: ip_address.to_i)
end

clear_all
friendly_resources_amount = 1
(1..friendly_resources_amount).each do |n|
  friendly_resource = new_friendly_resource(
    "demo_#{n}",
    IPAddr.new("79.181.31.#{n}")
  )
  friendly_resource.save
end
