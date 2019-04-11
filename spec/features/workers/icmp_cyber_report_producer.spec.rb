# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workers - ICMP Flood Report Producer', type: :feature do
  context 'A season of prior data is known' do
    before(:all) do
      friendly_resource = Departments::Archive::Api.instance.new_friendly_resource('demo_1', '79.181.31.4')
      Departments::Archive::Api.instance.persist_friendly_resource(friendly_resource)
      hw_forecasting_api = Algorithms::HoltWintersForecasting::Api.instance
      min = hw_forecasting_api.min_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
      max = hw_forecasting_api.max_seasonal_index(Algorithms::HoltWintersForecasting::ICMP_FLOOD)
      (min..max).each do |n|
        seasonal_indices = { current: n, previous: n - 1, next: n + 1 }
        seasonal_indices[:previous] = max if n == min
        seasonal_indices[:next] = min if n == max
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
      end
    end
    subject(:archive_api) { Departments::Archive::Api.instance }
    let(:friendly_resource) { archive_api.friendly_resources(1, 1).first }
    let(:cyber_report_type) { Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT }
    let(:flood_amount_of_attacks) { 2000 }
    let(:min_seasonal_index) { 100 }
    let(:max_seasonal_index) { 200 }
    let(:legal_amount_of_requests) { 300 }

    it 'Identifies aberrant behavior when it is present.' do
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
      expect(cyber_report.aberrant_behavior).to be true
    end

    it 'Does not identify aberrant behavior when it is not present.' do
      (min_seasonal_index..max_seasonal_index).each do |n|
        seasonal_indices = { current: n, previous: n - 1, next: n + 1 }
        seasonal_indices[:previous] = max_seasonal_index if n == min_seasonal_index
        seasonal_indices[:next] = min_seasonal_index if n == max_seasonal_index
        Workers::Analysis::Dos::Icmp::CyberReportProducer.new.perform(
          friendly_resource.ip_address,
          Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT,
          {
            'ip' => friendly_resource.ip_address,
            'incoming_req_count' => legal_amount_of_requests,
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
        expect(cyber_report.aberrant_behavior).to be false
      end
    end
  end
end
