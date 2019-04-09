# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IntelligenceApi', type: :feature do
  subject(:intelligence_api) { Departments::Analysis::Api.instance }
  let(:legal_query) {
    Departments::Shared::IntelligenceQuery.new(
      IPAddr.new('79.181.31.4').to_i,
      Departments::Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT
    )
  }
  let(:illegal_queries) {
    [
      nil,
      1,
      '2',
      {},
      [],
      Departments::Shared::IntelligenceQuery.new(
        -1,
        Departments::Shared::IntelligenceFormat::ICMP_DOS_CYBER_REPORT
      ),
      Departments::Shared::IntelligenceQuery.new(
        IPAddr.new('79.181.31.4').to_i,
        'Not good'
      )
    ]
  }

  it 'Throws an error when starting the intelligence gathering with an illegal query.' do
    illegal_queries.each do |query|
      expect {
        intelligence_api.start_intelligence_gathering(query)
      }.to raise_error(StandardError)
    end
  end

  it 'Throws an error when stopping the intelligence gathering with an illegal query.' do
    illegal_queries.each do |query|
      expect {
        intelligence_api.stop_intelligence_gathering(query)
      }.to raise_error(StandardError)
    end
  end
end
