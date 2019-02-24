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
  min = 0
  max = 120
  (min..max).each do |t|
    seasonal_indices = { current: n, previous: t - 1, next: t + 1 }
    seasonal_indices[:previous] = max if t == min
    seasonal_indices[:next] = min if t == max
    Workers::Analysis::Dos::Icmp::CyberReportProducer.new.perform(
      friendly_resource.ip_address,
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
      {
        ip: friendly_resource.ip_address,
        incoming_req_count: rand(100..1000),
        seasonal_indices: seasonal_indices
      },
      log: false
    )
  end
end
