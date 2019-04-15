# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ThinkTankApi', type: :feature do
  let(:think_tank_api) { Departments::ThinkTank::Api.instance }
  let(:legal_ip) { IPAddr.new('79.181.31.4').to_i }
  let(:legal_dos_icmp_intelligence_data) { { 'incoming_req_count' => 13 } }
  let(:legal_cyber_report_type) { Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT }
  let(:legal_page) { 1 }
  let(:legal_page_size) { 1 }
  let(:legal_sql_injection_intelligence_data) {
    [
      { 'params' => 'DROP DATABASE test;', 'payload' => 'DROP DATABASE test;' },
      { 'params' => 'DROP DATABASE test;' },
      { 'payload' => 'DROP DATABASE test;' }
    ]
  }
  let(:illegal_ids) {
    [nil, '1', '1.3.4', -1, {}, []]
  }
  let(:illegal_ips) {
    [nil, '1', -1, '1.3.4', {}, []]
  }
  let(:illegal_dos_icmp_intelligence_data) {
    [
      nil,
      1,
      '2',
      [],
      { 'not_incoming_req_count' => 12 },
      { 'incoming_req_count' => -1 },
      { 'not_incoming_req_count' => '2' }
    ]
  }
  let(:illegal_cyber_report_types) {
    [nil, 1, '12', {}, []]
  }
  let(:illegal_pages) {
    [nil, '1', 0, -1]
  }
  let(:illegal_page_sizes) {
    [nil, '1', 0, -1]
  }
  let(:illegal_sql_injection_intelligence_data) {
    [
      nil,
      1,
      '2',
      { 'not_params' => 'DROP DATABASE test;' },
      { 'not_payload' => 'DROP DATABASE test' },
      { 'params' => 1 },
      { 'payload' => 2 }
    ]
  }

  it 'Throws an error when starting the monitoring with an illegal friendly resource id.' do
    illegal_ids.each do |id|
      expect {
        think_tank_api.start_monitoring(id)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when stopping the monitoring with an illegal friendly resource id.' do
    illegal_ids.each do |id|
      expect {
        think_tank_api.stop_monitoring(id)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when analyzing dos icmp intelligence data with an illegal ip address.' do
    illegal_ips.each do |ip|
      expect {
        think_tank_api.analyze_icmp_dos_intelligence_data(ip, legal_dos_icmp_intelligence_data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when analyzing dos icmp intelligence data with an illegal dos icmp intellligence.' do
    illegal_dos_icmp_intelligence_data.each do |data|
      expect {
        think_tank_api.analyze_icmp_dos_intelligence_data(legal_ip, data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when analyzing sql injection intelligence data with an illegal ip address.' do
    illegal_ips.each do |ip|
      expect {
        think_tank_api.analyze_sql_injection_intelligence_data(ip, legal_sql_injection_intelligence_data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when analyzing sql injection intelligence data with an illegal sql injection intelligence' do
    illegal_sql_injection_intelligence_data.each do |data|
      expect {
        think_tank_api.analyze_sql_injection_intelligence_data(legal_ip, data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when getting latest cyber reports graph with an illegal cyber report type.' do
    illegal_cyber_report_types.each do |type|
      expect {
        think_tank_api.latest_cyber_reports_graph(type, legal_ip, legal_page, legal_page_size)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when getting latest cyber reports graph with an illegal ip address.' do
    illegal_ips.each do |ip|
      expect {
        think_tank_api.latest_cyber_reports_graph(legal_cyber_report_type, ip, legal_page, legal_page_size)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when getting latest cyber reports graph with an illegal page.' do
    illegal_pages.each do |page|
      expect {
        think_tank_api.latest_cyber_reports_graph(legal_cyber_report_type, legal_ip, page, legal_page_size)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when getting latest cyber reports graph with an illegal page size.' do
    illegal_page_sizes.each do |size|
      expect {
        think_tank_api.latest_cyber_reports_graph(legal_cyber_report_type, legal_ip, legal_page, size)
      }.to raise_error(StandardError)
    end
  end

  it 'Paginates over latest cyber reports by type and ip address.' do
    friendly_resource = Departments::Archive::Api.instance.new_friendly_resource('demo_1', legal_ip)
    friendly_resource.save
    (0..5).each do |n|
      next_cyber_report = Departments::Archive::Api.instance.new_cyber_report_object_for_friendly_resource(
        friendly_resource.ip_address,
        legal_cyber_report_type,
        'seasonal_index' => n
      )
      next_cyber_report.save
    end
    graph = think_tank_api.latest_cyber_reports_graph(
      legal_cyber_report_type,
      friendly_resource.ip_address,
      legal_page,
      legal_page_size
    )
    expect(
      graph[0][:data].size == graph[1][:data].size && graph[0][:data].size == legal_page_size
    ).to be_truthy
    graph = think_tank_api.latest_cyber_reports_graph(
      legal_cyber_report_type,
      friendly_resource.ip_address,
      2,
      2
    )
    expect(
      graph[0][:data].size == graph[1][:data].size && graph[0][:data].size == 2
    ).to be_truthy
    graph = think_tank_api.latest_cyber_reports_graph(
      legal_cyber_report_type,
      friendly_resource.ip_address,
      4,
      2
    )
    expect(
      graph[0][:data].size == graph[1][:data].size && graph[0][:data].empty?
    ).to be_truthy
  end

  it 'Throws an error when testing necessity for the collection of icmp dos intelligence data by illegal ip.' do
    illegal_ips.each do |ip|
      expect {
        think_tank_api.icmp_dos_intelligence_collection?(ip)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when testing necessity for the collection of sql injection intelligence data by illegal ip.' do
    illegal_ips.each do |ip|
      expect {
        think_tank_api.sql_injection_intelligence_collection?(ip)
      }.to raise_error(StandardError)
    end
  end
end
