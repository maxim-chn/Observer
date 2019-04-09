# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AnalysisApi', type: :feature do
  subject(:analysis_api) { Departments::Analysis::Api.instance }
  let(:legal_query) {
    Departments::Shared::AnalysisQuery.new(
      IPAddr.new('79.181.31.4').to_i,
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
    )
  }
  let(:legal_data) {
    { 'incoming_req_count' => 12 }
  }
  let(:illegal_queries) {
    [nil, 1, '2', {}, []]
  }
  let(:illegal_data) {
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

  it 'Throws an error when requesting a cyber report with an illegal query.' do
    illegal_queries.each do |query|
      expect {
        analysis_api.request_cyber_report(query, legal_data)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when requesting a cyber report with an illegal data.' do
    illegal_data.each do |data|
      expect {
        analysis_api.request_cyber_report(legal_query, data)
      }.to raise_error(StandardError)
    end
  end
end
