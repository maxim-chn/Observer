# frozen_string_literal: true

require 'rails_helper'
require 'logger'

RSpec.describe 'Positive True', type: :feature do
  context 'A season of prior data is known' do
    before(:all) do
      friendly_resource_ip = FactoryGirl.create(:friendly_resource).ip_address.to_i
      hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
      min = hw_forecasting_api.min_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
      max = hw_forecasting_api.max_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
      (min..max).each do |n|
        puts "Past #{n} records with legal amount of icmp requests, each." if n % 1000 == 0
        seasonal_indices = { current: n, previous: n - 1, next: n + 1 }
        seasonal_indices[:previous] = max if n == min
        seasonal_indices[:next] = min if n == max
        Workers::Analysis::Dos::Icmp::CyberReportProducer.new.perform(
          friendly_resource_ip,
          Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
          {
            'ip' => friendly_resource_ip,
            'incoming_req_count' => rand(100..1000),
            'seasonal_indices' => seasonal_indices
          },
          log: false
        )
      end
    end
    subject(:archive_api) { Departments::Archive::Api.instance }
    let(:friendly_resource) { archive_api.friendly_resources(1, 1).first }
    let(:cyber_report_type) { Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT }
    let(:flood_amount_of_attacks) { 2000 }

    it 'Identifies aberrant behavior' do
      puts 'Sending a record with twice the maximum legal amount of icmp requests.'
      Workers::Analysis::Dos::Icmp::CyberReportProducer.new.perform(
        friendly_resource.ip_address,
        Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
        {
          'ip' => friendly_resource.ip_address,
          'incoming_req_count' => flood_amount_of_attacks
        },
        log: false
      )
      cyber_report = archive_api.cyber_reports_by_friendly_resource_ip_and_type(
        friendly_resource.ip_address,
        cyber_report_type,
        1,
        1
      ).first
      puts 'Cyber Report at the moment of DoS Flood Attack ['
      cyber_report_json = JSON.parse(cyber_report.inspect)
      cyber_report_json.each do |k, v|
        puts "#{k} : #{v}"
      end
      puts ']'
      expect(cyber_report.aberrant_behavior).to be true
    end
    let(:min_seasonal_index) { 0 }
    let(:max_seasonal_index) { 100 }

    it 'Has confidence_band_upper_value formidable to instant changes' do
      (min_seasonal_index..max_seasonal_index).each do |n|
        puts "Past #{n} records with ICMP Flood amount of requests." if n % 1000 == 0
        seasonal_indices = { current: n, previous: n - 1, next: n + 1 }
        seasonal_indices[:previous] = max_seasonal_index if n == min_seasonal_index
        seasonal_indices[:next] = min_seasonal_index if n == max_seasonal_index
        Workers::Analysis::Dos::Icmp::CyberReportProducer.new.perform(
          friendly_resource.ip_address,
          Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
          {
            'ip' => friendly_resource.ip_address,
            'incoming_req_count' => flood_amount_of_attacks,
            'seasonal_indices' => seasonal_indices
          },
          log: false
        )
        cyber_report = archive_api.cyber_reports_by_friendly_resource_ip_and_type(
          friendly_resource.ip_address,
          cyber_report_type,
          1,
          1
        ).first
        expect(cyber_report.aberrant_behavior).to be true
      end
    end
  end
end
