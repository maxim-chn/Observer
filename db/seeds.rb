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
  hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
  min = hw_forecasting_api.min_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
  max = hw_forecasting_api.max_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
  (min..max).each do |t|
    Rails.logger.info("Past #{t} records with legal amount of icmp requests, each.") if (t % 100).zero?
    seasonal_indices = { current: t, previous: t - 1, next: t + 1 }
    seasonal_indices[:previous] = max if t == min
    seasonal_indices[:next] = min if t == max
    Workers::Analysis::Dos::Icmp::CyberReportProducer.new.perform(
      friendly_resource.ip_address,
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
      {
        'ip' => friendly_resource.ip_address,
        'incoming_req_count' => rand(100..1000),
        'seasonal_indices' => seasonal_indices
      },
      log: false
    )
    # sleep(1)
  end
end
