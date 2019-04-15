# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AnalysisApi', type: :feature do
  subject(:analysis_api) { Departments::Analysis::Api.instance }
  let(:legal_icmp_flood_report_query) {
    Departments::Shared::AnalysisQuery.new(
      IPAddr.new('79.181.31.4').to_i,
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
    )
  }
  let(:legal_sql_injection_report_query) {
    Departments::Shared::AnalysisQuery.new(
      IPAddr.new('79.181.31.4').to_i,
      Departments::Shared::AnalysisType::SQL_INJECTION_CYBER_REPORT
    )
  }
  let(:legal_icmp_flood_intelligence_data) {
    { 'incoming_req_count' => 12 }
  }
  let(:legal_sql_injection_intelligence_data) {
    { 'params' => 'DROP DATABASE test;', 'payload' => 'DROP DATABASE test;' }
  }
  let(:illegal_queries) {
    [nil, 1, '2', {}, []]
  }
  let(:illegal_icmp_flood_intelligence_data) {
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

  it 'Throws an error when requesting an ICMP Flood cyber report with an illegal query.' do
    illegal_queries.each do |query|
      expect {
        analysis_api.request_cyber_report(query, legal_icmp_flood_intelligence_data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when requesting an ICMP Flood cyber report with an illegal intelligence data.' do
    illegal_icmp_flood_intelligence_data.each do |data|
      expect {
        analysis_api.request_cyber_report(legal_icmp_flood_report_query, data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when requesting a SQL Injection cyber report with an illegal query.' do
    illegal_queries.each do |query|
      expect {
        analysis_api.request_cyber_report(query, legal_sql_injection_intelligence_data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when requesting a SQL Injection cyber report with an illegal intelligence data.' do
    illegal_sql_injection_intelligence_data.each do |data|
      expect {
        analysis_api.request_cyber_report(legal_icmp_flood_report_query, data)
      }.to raise_error(StandardError)
    end
  end
end
