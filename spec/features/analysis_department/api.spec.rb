# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AnalysisApi', type: :feature do
  subject(:analysis_api) { Departments::Analysis::Api.instance }
  let(:illegal_query) { nil }
  let(:illegal_data) { 3 }
  let(:legal_query) {
    Departments::Shared::AnalysisQuery.new(
      IPAddr.new('79.181.31.4').to_i,
      Departments::Shared::AnalysisType::ICMP_DOS_CYBER_REPORT
    )
  }
  let(:legal_data) {
    { 'incoming_req_count' => 12 }
  }

  it 'Throws an error when illegal query & legal data' do
    expect {
      analysis_api.request_cyber_report(illegal_query, legal_data)
    }.to raise_error(StandardError)
  end

  it 'Throws an error when legal query & illegal data' do
    expect {
      analysis_api.request_cyber_report(legal_query, illegal_data)
    }.to raise_error(StandardError)
  end
end
